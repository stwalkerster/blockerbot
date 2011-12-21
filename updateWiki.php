<?php

$url = "https://s3-eu-west-1.amazonaws.com/minecraft-worlds/smp/mc1/";
$pw = "Help2204Bot";
$un = "Helpmebot";
$page = "Template:Mc1-backup";


$text = "";

$result = shell_exec("s3cmd ls s3://minecraft-worlds/smp/mc1/2");
$result = explode("\n", $result);
$result = array_filter($result);
$data = array();
foreach($result as $val)
{
	$arrayval = explode(" " ,$val);
	unset($arrayval[0]);
	unset($arrayval[1]);
	$arrayval[6] = str_replace("s3://minecraft-worlds/smp/mc1/", "", $arrayval[6]);
	$arrayval[6] = str_replace(".tar.bz2", "", $arrayval[6]);
	$d = DateTime::createFromFormat("Y-m-d\THis\Z", $arrayval[6]);
	$arrayval[] = $d->format("l d F Y H:i:s");
	$arrayval = array_filter($arrayval);
	$arrayval =array_values( $arrayval);
	$data[] = $arrayval;
	$size = ($arrayval[0] / 1024) / 1024;
	$text .= '* '.$arrayval[2].' : ['.$url.$arrayval[1].'.tar.bz2 Download] ('.number_format($size,2)." MB)\n";
}

$api = "http://helpmebot.org.uk/w/api.php";
$settings['cookiefile'] = "cookies.tmp";

function httpRequest($url, $post="") {
        global $settings;

        $ch = curl_init();
        //Change the user agent below suitably
        curl_setopt($ch, CURLOPT_USERAGENT, 'MinecraftBackupScript/1.0 cURL/PHP');
        curl_setopt($ch, CURLOPT_URL, ($url));
        curl_setopt( $ch, CURLOPT_ENCODING, "UTF-8" );
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt ($ch, CURLOPT_COOKIEFILE, $settings['cookiefile']);
        curl_setopt ($ch, CURLOPT_COOKIEJAR, $settings['cookiefile']);
        if (!empty($post)) curl_setopt($ch,CURLOPT_POSTFIELDS,$post);
        $xml = curl_exec($ch);
        if (!$xml) {
                throw new Exception("Error getting data from server ($url): " . curl_error($ch));
        }

        curl_close($ch);
        return $xml;
}

//////////// LOGIN
$apiresult = httpRequest($api, array(
	"format" => "php",
	"action" => "login",
	"lgname" => $un,
	"lgpassword" => $pw,
	"lgdomain" => "Helpmebot SSO",
	));

$apiresult = unserialize($apiresult);

$apiresult = httpRequest($api, array(
	"format" => "php",
	"action" => "login",
	"lgname" => $un,
	"lgpassword" => $pw,
	"lgdomain" => "Helpmebot SSO",
	"lgtoken" => $apiresult["login"]["token"],
	));

$apiresult = unserialize($apiresult);

/////////////// GET EDIT TOKEN

$apiresult = httpRequest($api, array(
	"format" => "php",
	"action" => "query",
	"prop" => "info",
	"intoken" => "edit",
	"titles" => $page,
	));

$apiresult = unserialize($apiresult);

$token = $apiresult["query"]["pages"]["629"]["edittoken"];

////////////////// EDIT

$apiresult = httpRequest($api, array(
	"format" => "php",
	"action" => "edit",
	"token" => $token,
	"summary" => "Update data from Minecraft Backup script",
	"text" => $text,
	"title" => $page
	));

$apiresult = unserialize($apiresult);

print_r($data);

print_r($apiresult);


