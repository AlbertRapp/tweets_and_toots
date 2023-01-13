document.addEventListener('input', function(event) {
  var text_areas = document.getElementsByTagName('textarea'); 

  function resize(text) {
        text.style.height = 'auto';
        text.style.height = 1.1 * text.scrollHeight+'px';
  }

  [...Array(text_areas.length).keys()].map(x => resize(text_areas[x]));
});