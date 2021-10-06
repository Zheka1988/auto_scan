$(document).on('turbolinks:load', function(){
  $('.countries').on('click', '.link-scan-op', function(e) {
    e.preventDefault();
    var id = $(this).data('id');
    $('.countries #country-'+ id +' .nmap-scan-op-country .nmap-scan-op').hide();
    $('.countries #country-'+id +' .nmap-scan-op-country ').append("<h4 class='text-success'>In process</h4>");
  })
});