$(function() {
  $(".fadeout").delay(2000).fadeOut(600);
  $('.carousel').carousel({
    cycle: false,
    interval: false
  });
  $('#myCarousel').children('.left.carousel-control').hide();

  $('#myCarousel').on('slid', '', function() {
    var $this = $(this);

    $this.children('.carousel-control').show();

    if($('.carousel-inner .item:first').hasClass('active')) {
      $this.children('.left.carousel-control').hide();
    } else if($('.carousel-inner .item:last').hasClass('active')) {
      $this.children('.right.carousel-control').hide();
    }

  });
});