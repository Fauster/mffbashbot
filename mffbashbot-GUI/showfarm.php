<?php
// Show farm file for My Free Farm Bash Bot (front end)
// Copyright 2016-20 Harun "Harry" Basalamah
// Parts of the graphics used are Copyright upjers GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
if (!isset($_POST["farm"]))
 header("Location: index.php");
$farm = $_POST["farm"];
strpos($_POST["username"], ' ') === false ? $username = $_POST["username"] : $username = rawurlencode($_POST["username"]);
include 'config.php';
include 'lang.php';
include 'functions.php';
include 'farmdata.php';
include 'header.php';
include 'buttons.php';

// headings
for ($position = 1; $position <= 3; $position++) {
 $iNumQueues = GetQueueCount($gamepath, $farm, $position);
 print "<table id=\"t$position\" class=\"queuetable\" border=\"1\">";
 print "<tr><th colspan=\"$iNumQueues\">" . (!empty($farmdata["updateblock"]["farms"]["farms"]["$farm"]["$position"]["name"]) ? $farmdata["updateblock"]["farms"]["farms"]["$farm"]["$position"]["name"] : $strings['notavailable']) . "</th>";
 print "</tr><tr>";
 print "<td align=\"center\" colspan=\"$iNumQueues\"><form action=\"makeW3Chappy\" name=\"selpos$position\" style=\"margin-bottom:0\">";
 CreateSelectionsForBuildingID($farmdata["updateblock"]["farms"]["farms"]["$farm"]["$position"]["buildingid"], $position);
 print "</form></td>";
 print "</tr><tr>";
// buttons
 for ($i = 1; $i <= $iNumQueues; $i++) {
  print "<td align=\"center\">\n";
  print "<form action=\"makeW3Chappy\" style=\"margin-bottom:0\">";
  PlaceQueueButtons($position, $i);
  print "</form></td>";
 }
 print "</tr><tr>";
// queues
 print"<td align=\"center\" colspan=\"$iNumQueues\">";
 print "<form name=\"queue$position\" id=\"queue$position\" action=\"makeW3Chappy\" style=\"margin-bottom:0\">";
 for ($i = 1; $i <= $iNumQueues; $i++)
  PlaceQueues($gamepath, $farm, $position, $i);
 print "</form></td>";
 print "</tr></table>";
}
print "<div style=\"clear:both\"></div>";
print "<br>";
print "<form name=\"save_form\" id=\"saveConfig_form\" method=\"post\" action=\"save.php\" style=\"display: inline-block; margin-right: 2em\">";
print "<button class=\"btn btn-success btn-sm\" name=\"save\" onclick=\"return saveConfig()\">{$strings['save']}</button>";
print "</form>{$strings['insert-multiplier']}&nbsp;<input id=\"multi\" type=\"text\" maxlength=\"2\" size=\"1\" value=\"1\" pattern=\"[0-9]{1,2}\"><br><br>\n";

for ($position = 4; $position <= 6; $position++) {
 $iNumQueues = GetQueueCount($gamepath, $farm, $position);
 print "<table id=\"t$position\" class=\"queuetable\" border=\"1\">";
 print "<tr><th colspan=\"$iNumQueues\">" . (!empty($farmdata["updateblock"]["farms"]["farms"]["$farm"]["$position"]["name"]) ? $farmdata["updateblock"]["farms"]["farms"]["$farm"]["$position"]["name"] : $strings['notavailable']) . "</th>";
 print "</tr><tr>";
 print "<td align=\"center\" colspan=\"$iNumQueues\"><form id=\"selpos$position\" name=\"selpos$position\" action=\"makeW3Chappy\" style=\"margin-bottom:0\">";
 CreateSelectionsForBuildingID($farmdata["updateblock"]["farms"]["farms"]["$farm"]["$position"]["buildingid"], $position);
 print "</form></td>";
 print "</tr><tr>";
 for ($i = 1; $i <= $iNumQueues; $i++) {
  print "<td align=\"center\">\n";
  print "<form action=\"makeW3Chappy\" style=\"margin-bottom:0\">";
  PlaceQueueButtons($position, $i);
  print "</form></td>";
 }
 print "</tr><tr>";
 print"<td align=\"center\" colspan=\"$iNumQueues\">";
 print "<form name=\"queue$position\" id=\"queue$position\" action=\"makeW3Chappy\" style=\"margin-bottom:0\">";
 for ($i = 1; $i <= $iNumQueues; $i++)
  PlaceQueues($gamepath, $farm, $position, $i);
 print "</form></td>";
 print "</tr></table>";
}
?>
 </body>
</html>
