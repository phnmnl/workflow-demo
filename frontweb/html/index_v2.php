
<?php

// include_once ("dbfunctions.php");
require "header.php";

// get available images from docker hub with rest API
$response = file_get_contents('https://index.docker.io/v1/search?q=farmbio');
$searchResult = json_decode($response, true); // decode the JSON into a

?>
 <!-- <?php echo $response ?> -->
 
 <div id="" class="contentwrap">
	 
	 <div style="padding-left: 0px; padding-top: 20px" class="center-block">
	 <div class="row" >
	  <div class="col-sm-1"></div>
      <div class="col-sm-5">
	   <img width="300" class="center-block" src="resources/phenomenal-header-logo.png">
	  </div>	
	  <div class="col-sm-5">
	   <img width="260" class="center-block" src="resources/scilife_lab_logo.png">
	  </div>
	<div class="col-sm-1"></div>
	</div>
	</div>

<br>

  <div id="extradiv" style="padding-left: 10px; padding-top: 0px">
    
    
    <div class="row" >
		
	  <div class="col-sm-1"></div>
	  
      <div class="col-sm-10">
     
	    <h4>Available Phenomenal services in Docker hub</h4>
     
	   <div id="tablewrapper" class="tablewrap">
       
	     <table class="table table-condensed">
	       <!-- Header-->
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
		
	   <div class="col-sm-1"></div>

	 </div> 
	 
	 
	 <br><br>
	
	<div class="row">
		 <div class="col-sm-1"></div>
         <div class="col-sm-10 text-center">  
            <a class="btn btn-primary btn-lg" name="return" href="">Run via Jupyter</a>
            <a class="btn btn-primary btn-lg" name="return" href="">Run via Chronos</a>
         </div>
         <div class="col-sm-1"></div>
     </div>
     
     <br><br><br>
	 
	 <div class="row">
		 <div class="col-sm-1"></div>
         <div class="col-sm-10">  
	 <h3>Cloud servers status......</h3>
	 
		</div>
         <div class="col-sm-1"></div>
     </div>
	 
	</div> <!-- end extradiv -->
</div> 



<?php require "footer.php" ?>
