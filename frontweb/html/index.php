
<?php

$pageTitle = "Phenomenal cloud services";
require "header.php";

// get available images from docker hub with rest API
$response = file_get_contents("https://index.docker.io/v1/search?q=farmbio");
$searchResult = json_decode($response, true);

?>
 <!-- <?php echo $response ?> -->
 
 <div id="" class="contentwrap">
	 
	 <div class="row" >
      <div class="col-sm-10">
	 	          
	<div style="padding-left: 0px; padding-top: 20px">
	   <img width="280" src="resources/phenomenal-header-logo.png">	
	  <!-- <img width="240" src="resources/scilife_lab_logo.png"> -->
	  <!-- <img width="260" src="resources/UPPMAX.png">	-->
	</div>
	
	</div>
	 </div>

<br>

  <div id="extradiv" style="padding-left: 10px; padding-top: 0px">
    
    
    <div class="row" >
      <div class="col-sm-10">
     
	   <div id="tablewrapper" class="tablewrap">
		 
		 <h4>Available Phenomenal services in Docker hub</h4>
       
	     <table class="table table-condensed">
	       
	       <thead>
	   	     <tr>
	   	       <th class="col-sm-4">Name</th>
	   	       <th class="col-sm-4">Description</th>
	   	     </tr>	
           </thead>
       
	   	   <!--Populate the table with the json search result-->
	   	   <tbody>
             <?php foreach($searchResult['results'] as $key => $row): ?>
                <tr>
                  <td><?php echo $row['name']; ?></td>
                  <td><?php echo $row['description']; ?></td>
                </tr>
             <?php endforeach; ?>
           </tbody>
	   	 
	     </table>
	   </div>	<!-- end tablediv -->
	  </div>
	 </div> 
	 
	 
	 <br><br><br>
	
	<div class='row'>
         <div class="col-sm-10">  
            <a class="btn btn-primary btn-lg" name="return" href="">Start Jupyter</a>
            <a class="btn btn-primary btn-lg" name="return" href="">Start Galaxy</a>
         </div>
     </div>
     
     <br><br><br><br>
	 
	 
	</div> <!-- end extradiv -->
</div> 



<?php require "footer.php" ?>
