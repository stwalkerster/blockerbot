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

$settings['blockreason'] = "Go away.";
$settings['blockexpiry'] = "4 weeks";

$settings['userfile'] = "list.txt";
$settings['eol'] = "\r\n";

///////////////////////////////////////////////////////////////////////////////////////////////////////

$file = file_get_contents($settings['userfile']);
$userlist = explode($settings['eol'], $file);

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

foreach($userlist as $user)
{
/////////////////////////////// GET BLOCK TOKEN

$apiresult = httpRequest($settings['api'], array(
	"format" => "php",
	"action" => "query",
	"prop" => "info",
	"intoken" => "block",
	"titles" => $user,
	));

$apiresult = unserialize($apiresult);
echo "########## Token:\n";

$token = "";
foreach($apiresult["query"]["pages"] as $fragment)
	if(isset($fragment["blocktoken"]))
		$token = $fragment["blocktoken"];
		
if($token == ""){
	print_r($apiresult);
	die();
}
////////////////// BLOCK

$apiresult = httpRequest($settings['api'], array(
	"format" => "php",
	"action" => "block",
	"token" => $token,
	"reason" => $settings['blockreason'],
	"expiry" => $settings['blockexpiry'],
	"user" => $user
	));

$apiresult = unserialize($apiresult);

echo "########## Block completion:\n";

if(!isset($apiresult["block"]))
	die( "Block failed.");

}