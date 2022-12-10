<?php

if (isset($_SERVER['HTTP_X_ORIGINAL_FORWARDED_FOR'])) {
	$r = explode(',', $_SERVER['HTTP_X_ORIGINAL_FORWARDED_FOR']);
	$_SERVER['REMOTE_ADDR'] = preg_replace('/[^0-9A-Fa-f\:\.]/', '', $r[0]);
	unset($r);
}
else if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
	$r = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR']);
	$_SERVER['REMOTE_ADDR'] = preg_replace('/[^0-9A-Fa-f\:\.]/', '', $r[0]);
	unset($r);
}

// If we're behind a proxy server and using HTTPS, we need to alert Wordpress of that fact
// see also http://codex.wordpress.org/Administration_Over_SSL#Using_a_Reverse_Proxy
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
	$_SERVER['HTTPS'] = 'on';
}