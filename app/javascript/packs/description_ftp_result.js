$(document).on('turbolinks:load', function(){
  $('.ftp-results').on('click', '.added-ftp-description-link', function(e) {
    e.preventDefault();
    $(this).hide();
    var ftpResultId = $(this).data('ftpResultId');
    $('#added-ftp-description-'+ ftpResultId).removeClass('hidden');
  });
});