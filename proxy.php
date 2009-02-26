<?php 
 
$url = urldecode($_GET["url"]); 
header("Content-Type: text/html"); 
readfile($url); 

 
?>