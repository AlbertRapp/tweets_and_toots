getMessages = function(x) {
  var msg_query = document.querySelectorAll(
    'div.card.bs4Dash:not([style*="display: none;"]) textarea[id*="twitter-message"]'
  );
  var msgs = [...Array(msg_query.length).keys()].map(x => msg_query[x].value);
  Shiny.setInputValue('msgs_twitter', msgs);
  
  var msg_query = document.querySelectorAll(
    'div.card.bs4Dash:not([style*="display: none;"]) textarea[id*="mastodon-message"]'
  );
  var msgs = [...Array(msg_query.length).keys()].map(x => msg_query[x].value);
  Shiny.setInputValue('msgs_mastodon', msgs);
  return msgs
};

