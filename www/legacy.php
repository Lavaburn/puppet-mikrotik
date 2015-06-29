<html>
	<head>
		<title>RCS WiMAX Juba - Manually push CPE to ERP</title>
	</head>
	<body>
		<?php 
			$DB1 = new mysqli('tools.dmz.rcswimax.com', 'wimax', 'aperto', 'wimax_summary');
			$DB2 = new mysqli('tools.dmz.rcswimax.com', 'wimax', 'aperto', 'wimax_summary_bts2');
			$DB3 = new mysqli('tools.dmz.rcswimax.com', 'statistics', 'wimax2013juba', 'wimax_stats');
		?>
		<h1>Manually push CPE to ERP</h1>
		<p>You can only push CPEs that have been loaded into the local database. This local database is updated at:
			<ul>
				<li>06:05 EAT (Airspan)</li>
				<li>07:05 EAT (Airspan)</li>
				<li>08:00 - 08:05 EAT</li>
				<li>09:05 EAT (Airspan)</li>				
				<li>10:00 - 10:05 EAT</li>
				<li>11:05 EAT (Airspan)</li>
				<li>12:00 - 12:05 EAT</li>
				<li>13:05 EAT (Airspan)</li>
				<li>14:00 - 14:05 EAT</li>
				<li>15:05 EAT (Airspan)</li>
				<li>16:00 - 16:05 EAT</li>
				<li>17:05 EAT (Airspan)</li>
				<li>18:00 - 18:05 EAT</li>
				<li>19:05 EAT (Airspan)</li>
				<li>20:00 - 20:05 EAT</li>
				<li>21:05 EAT (Airspan)</li>
				<li>22:05 EAT (Airspan)</li>			
			</ul>
			* CPE needs to be online during this time<br />
			* New Airspan CPEs are pushed to the ERP at: 12:40, 16:40 and 20:40		<br />
			* All CPEs are updated to the ERP between 22:10 and 22:40		
		</p>
		<p style="color: red;">
		<?php 
			define("SCRIPTDIR", "/etc/scripts/erp/");		
		
			if (isset($_POST["type"])) {
				$MAC = $_POST["mac"];
				if ($_POST["type"] == "pm5000") {
					exec(SCRIPTDIR."aperto/upload_soap.php 172.20.1.1 wimax_summary $MAC");
					exec(SCRIPTDIR."aperto/upload_soap.php 172.20.1.5 wimax_summary_bts2 $MAC");

					echo "Pushed $MAC to ERP.";
				} else if ($_POST["type"] == "air4g") {
					exec(SCRIPTDIR."airspan/upload_soap.php $MAC");

					echo "Pushed $MAC to ERP.";
				}
			}
		?>
		</p>
		<h2>Aperto PM5000</h2>
			<form method="post">
				<input type="hidden" name="type" value="pm5000" />
				<select name="mac">
				<?php					
					$SQL = "SELECT value FROM cpe_config WHERE field =  'mac' GROUP BY value";
					$results[] = $DB1->query($SQL);
					$results[] = $DB2->query($SQL);
				
					foreach ($results as $res) {
						while ($row = $res->fetch_array()) {
							$MAC = str_replace(" ", ":", trim($row["value"]));							
							echo "<option value=\"$MAC\">$MAC</option>";
						}
						$res->free();					
					}					
				?>
				</select>
				<input type="submit" name="submit" value="Push"/>			
			</form>
		<h2>Airspan Air4G</h2>
			<form method="post">
				<input type="hidden" name="type" value="air4g" />
				<select name="mac">
				<?php
					$result3 = $DB3->query("SELECT mac FROM cpe_config");
					while ($row = $result3->fetch_array()) {
						$MAC = trim($row["mac"]);
						echo "<option value=\"$MAC\">$MAC</option>";
					}
					$result3->free();
				?>
				</select>								
				<input type="submit" name="submit" value="Push"/>			
			</form>
	</body>
</html>
