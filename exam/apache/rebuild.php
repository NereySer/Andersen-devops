<?php
$ar_apps = array('app1', 'app2');

/*
$gh_ips = array('171.149.246.236', '95.92.138.4');
if (in_array($_SERVER['REMOTE_ADDR'], $gh_ips) === false) {
    header('Status: 403 Your IP is not on our list; bugger off', true, 403);
    mail('root', 'Unfuddle hook error: bad ip', $_SERVER['REMOTE_ADDR']);
    die(1);
}
*/

//var_dump($_POST);
$head_commit = json_decode($_POST["payload"], true)["head_commit"];
$files = array_merge(
  $head_commit["added"],
  $head_commit["removed"],
  $head_commit["modified"]
);
var_dump($files);

foreach ($ar_apps as $app) {
  $matches  = preg_grep ("/^exam\/$app\/.*/i", $files);

  if ($matches !== NULL && count($matches)>0) {
    echo("Update app $app\n");

    echo(shell_exec("sudo -u admin /home/admin/rebuild_app ".$app));
  }
}

die("done " . mktime());

?>
