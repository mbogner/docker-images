<?php

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype = 'pgsql';
$CFG->dblibrary = 'native';
$CFG->dbhost = 'postgres';
$CFG->dbname = 'db';
$CFG->dbuser = 'admin';
$CFG->dbpass = 's3cr3t';
$CFG->prefix = 'mdl_';
$CFG->dboptions = [
    'dbpersist' => false,
    'dbsocket' => false,
    'dbport' => '5432',
    'dbhandlesoptions' => false,
    'dbcollation' => 'utf8mb4_unicode_ci',
];

$CFG->wwwroot = 'http://localhost';
$CFG->dataroot = '/data';
$CFG->routerconfigured = false;
$CFG->directorypermissions = 0777;
$CFG->admin = 'admin';

// Mailpit (internal SMTP in docker network)
$CFG->smtphosts = 'mail:1025';
$CFG->smtpsecure = ''; // no tls
$CFG->smtpuser = 'smtp';
$CFG->smtppass = 'pass123';
$CFG->noreplyaddress = 'noreply@example.com';

require_once(__DIR__ . '/lib/setup.php'); // Do not edit

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!
