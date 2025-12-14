#!/bin/bash
set -euo pipefail
cd /var/www/html

php occ config:system:set maintenance_window_start --type integer --value 1
php occ config:system:set default_phone_region --type string --value AT

php occ db:add-missing-indices
php occ maintenance:repair --include-expensive
