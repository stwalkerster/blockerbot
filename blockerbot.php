<?php
// initial configuration
$settings = array();

$settings['username']="Stwalkerster";
$settings['password']=""; // get from ext. file not in git.
$settings['domain'] = "Helpmebot SSO";

// retrieve password from other file.
require_once("wiki.password");

$settings['api'] = "http://helpmebot.org.uk/w/api.php";
$settings['cookiefile'] = "cookies.tmp";
$settings['useragent'] = 'BlockerBot/1.0 ( +http://github.com/stwalkerster/blockerbot ) cURL/php';

function httpRequest($url, $post="") {
        global $settings;

        $ch = curl_init();
        //Change the user agent below suitably
        curl_setopt($ch, CURLOPT_USERAGENT, $settings['useragent']);
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
$apiresult = httpRequest($settings['api'], array(
	"format" => "php",
	"action" => "login",
	"lgname" => $settings['username'],
	"lgpassword" => $settings['password'],
	"lgdomain" => $settings['domain'],
	));

$apiresult = unserialize($apiresult);
echo "########## Login part 1:\n";

if($apiresult["login"]["result"] != "NeedToken")
	die( "Login: {$apiresult["login"]["result"]}");

$apiresult = httpRequest($settings['api'], array(
	"format" => "php",
	"action" => "login",
	"lgname" => $settings['username'],
	"lgpassword" => $settings['password'],
	"lgdomain" => $settings['domain'],
	"lgtoken" => $apiresult["login"]["token"],
	));

$apiresult = unserialize($apiresult);
echo "########## Login part 2:\n";

if($apiresult["login"]["result"] != "Success")
	die( "Login: {$apiresult["login"]["result"]}");

/////////////////////////////// GET EDIT TOKEN

$apiresult = httpRequest($settings['api'], array(
	"format" => "php",
	"action" => "query",
	"prop" => "info",
	"intoken" => "edit",
//	"titles" => $page,
	));

$apiresult = unserialize($apiresult);
echo "########## Edit token:\n";

$token = "";
foreach($apiresult["query"]["pages"] as $fragment)
	if(isset($fragment["edittoken"]))
		$token = $fragment["edittoken"];
		
if($token == ""){
	print_r($apiresult);
	die();
}
////////////////// EDIT

$apiresult = httpRequest($settings['api'], array(
	"format" => "php",
	"action" => "edit",
	"token" => $token,
	"summary" => "Update data from Minecraft Backup script",
	"text" => $text,
//	"title" => $page
	));

$apiresult = unserialize($apiresult);

echo "########## Edit completion:\n";

if($apiresult["edit"]["result"] != "Success")
	die( "Login: {$apiresult["login"]["result"]}");

