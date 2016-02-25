
	 <!-- Modal dialog -->
	 <div class="modal" id="modalUserMessage" tabindex="-1" role="dialog" aria-labelledby="Confirm" aria-hidden="true">
		 <div class="modal-dialog">
		<div class="modal-content">
		<div class="modal-header">
			<button type="button" class="close" data-dismiss="modal" aria-hidden="true"><span class="glyphicon glyphicon-remove" aria-hidden="true"></span></button>
             <h4 class="modal-title custom_align" id="Heading">Message</h4>
		</div>
		<div class="modal-body">
			<p id="modalUserMessageParagraph">User message</p>
		</div>
		<div class="modal-footer">
			<button id="modalUserMessageCloseButton" type="button" class="btn btn-success" data-dismiss="modal">OK</button>
		</div>
	   </div> 
      </div> 
    </div> 
	

	<!-- FOOTER -->
	
	<nav class="navbar navbar-inverse navbar-fixed-bottom">
		  
	   <div class="navbar-text" style="padding-top: 0px; padding-bottom: 0px; padding-left: 35px">
		  <img style="float:left; padding-right: 20px;" src="http://europa.eu/about-eu/basic-information/symbols/images/flag_yellow_low.jpg" width="80">
		  PhenoMeNal is funded by European Commission's Horizon2020  programme,
	      <br>
	      grant agreement number 654241
	   </div>

    </nav>
	
	
	<!-- Additional javascripts -->
    <script src="js/jQueryRotate.js"></script>
    <script src="js/sha1.js"></script>
    <script src="datepicker/js/bootstrap-datepicker.min.js"></script>
    
    <script>
		
	    $(document).ready(function(){
			
		
        }); // End default document ready function
        
    <?php
       if(isset($_SESSION['usermessage'])): 
       
	      $userMessage = $_SESSION['usermessage'];
	 ?>
	      $(document).ready(function(){
	         $('#modalUserMessageParagraph').html('<?=$userMessage?>');
		     $('#modalUserMessage').modal('show');
		     $('#modalUserMessageCloseButton').focus();
          });
       
	<?php	    
	      unset($_SESSION['usermessage']);
	  endif
	?>
	
	    
    </script>
  
  </body>
</html>
