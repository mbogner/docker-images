# Tile38 leader/follower + HAProxy

Two [Tile38](https://tile38.com) nodes behind HAProxy.

- `tile1` — **leader** (writable), `config-leader.json`.
- `tile2` — **follower** (read-only replica of `tile1`), `config-follower.json`.
- `haproxy` — routes the TCP frontend `:9851` **only to whichever node is currently the leader**.

Both nodes share the same password: `requirepass: tile38pass` on each, plus
`leaderauth: tile38pass` on the follower so it can authenticate to the leader when replicating.
Because the password is symmetric, clients always use `AUTH tile38pass` no matter which node is
currently the leader.

HAProxy decides "who is leader" from the Tile38 Prometheus metrics on port `4321`:

```
backend tile38_servers
    option httpchk GET /metrics
    http-check expect rstring .*role.*leader.*
```

A node's metrics report `tile38_replication_info{...,role="leader"}` only when it is a leader.
Followers report `role="follower"` and therefore **fail the health check on purpose**. The
`/metrics` endpoint is **not** protected by `requirepass`, so the health check needs no auth.

## Ports

| Host                    | Purpose              | Auth          |
|-------------------------|----------------------|---------------|
| `127.0.0.1:9851`        | Tile38 (via HAProxy) | `tile38pass`  |
| `127.0.0.1:9000`        | HAProxy stats        | `admin:admin` |

## Auth note — every CLI command needs `AUTH`

Both nodes have `requirepass`, and `tile38-cli` has no `-a`/password flag. Send `AUTH` first,
then the command, over one connection:

```bash
docker compose exec -T tile1 sh -c 'printf "AUTH tile38pass\n<CMD>\n" | tile38-cli'
```

(`PING` and `/metrics` are the exceptions — they work without auth.)

## Start

```bash
docker compose up -d
```

## Expected state (nothing wrong)

In the HAProxy stats page (`http://127.0.0.1:9000`):

- `tile1` — **UP** (it is the leader).
- `tile2` — **DOWN** — this is correct. `tile2` is a follower, so it fails the
  `role=leader` health check by design. HAProxy never routes writes to a read-only replica.

## Failover is NOT automatic

Tile38 has **no automatic election/promotion** (no Sentinel equivalent). If the leader
dies, the follower stays a follower forever — it does **not** promote itself. HAProxy then
has zero healthy backends and the whole endpoint goes down until you promote `tile2` manually
(steps below).

---

## Manual failover — promote the follower to leader

When `tile1` (the leader) is dead, make `tile2` the new leader:

```bash
docker compose exec -T tile2 sh -c 'printf "AUTH tile38pass\nFOLLOW no one\n" | tile38-cli'
```

`FOLLOW no one` detaches `tile2` from its leader and turns it into a standalone leader.

Verify:

```bash
docker compose exec tile2 sh -c 'wget -qO- http://127.0.0.1:4321/metrics' | grep 'replication_info{'
# expect: ...role="leader"...
```

Once `tile2` reports `role="leader"`, its metrics start passing the HAProxy health check and
HAProxy automatically shifts traffic to it (within `inter 5s` × `rise 2`). No HAProxy change
needed. Because both nodes share the same password, clients keep using `AUTH tile38pass`
against the new leader with no change.

---

## Failback — restore `tile1` as leader

After `tile1` comes back, you now have **two leaders** (split-brain). Pick one procedure.

### A) Go back to the original topology (`tile1` leader, `tile2` follower)

Point `tile2` back at `tile1` (demotes `tile2` to follower again). `tile2` uses its
`leaderauth` from config to authenticate to `tile1`:

```bash
docker compose exec -T tile2 sh -c 'printf "AUTH tile38pass\nFOLLOW tile1 9851\n" | tile38-cli'
```

Verify:

```bash
docker compose exec tile1 sh -c 'wget -qO- http://127.0.0.1:4321/metrics' | grep 'replication_info{'
# tile1: role="leader"
docker compose exec tile2 sh -c 'wget -qO- http://127.0.0.1:4321/metrics' | grep 'replication_info{'
# tile2: role="follower", following="tile1:9851"
```

> **Data loss warning:** any writes taken by `tile2` while it was the emergency leader are
> discarded when it re-follows `tile1`. Only do this if `tile1` still holds the authoritative
> data, or after you have re-synced manually.

### B) Keep `tile2` as the new leader, make `tile1` follow it

```bash
docker compose exec -T tile1 sh -c 'printf "AUTH tile38pass\nFOLLOW tile2 9851\n" | tile38-cli'
```

`tile1` uses its `leaderauth` to authenticate against `tile2`.

---

## Config symmetry

Both nodes carry the same `requirepass` **and** `leaderauth: tile38pass`, so either node can be
leader or follower and clients always use `AUTH tile38pass` regardless of which node is active.

`config-leader.json`:

```json
{
  "leaderauth": "tile38pass",
  "requirepass": "tile38pass",
  "server_id": "db341db8282d50a6b1736490e7896418"
}
```

`config-follower.json` adds the `follow_host`/`follow_port` pointing at `tile1`.

## Quick reference

| Action                          | Command                                                                                       |
|---------------------------------|----------------------------------------------------------------------------------------------|
| Promote follower → leader       | `docker compose exec -T tile2 sh -c 'printf "AUTH tile38pass\nFOLLOW no one\n" \| tile38-cli'` |
| Demote a node → follower of X   | `docker compose exec -T tile2 sh -c 'printf "AUTH tile38pass\nFOLLOW tile1 9851\n" \| tile38-cli'` |
| Run any cmd on a node           | `docker compose exec -T tileN sh -c 'printf "AUTH tile38pass\n<CMD>\n" \| tile38-cli'`        |
| Check a node's role             | `docker compose exec tileN sh -c 'wget -qO- http://127.0.0.1:4321/metrics' \| grep 'replication_info{'` |
