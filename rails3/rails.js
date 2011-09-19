// This is document serves to handle javascript that was built into Rails 2.x but was removed in Rails 3.
// The unobtrusive javascript here makes use of the HTML5 tags introduced in Rails 3.

// ==================
// = Document Ready =
// ==================
$(function(){
  initializeRailsJavascript();
});

// ==========
// = Delete =
// ==========
function initializeRailsJavascript(){
  
  initializePost();
  initializePopups();
  
  function initializePopups(){
    $("a[popup], a[data-popup]").click(function(){
      window.open(this.href); return false;
    });
  }

  function initializePost(){
    $("a[data-method]").click(function(){
      var confirmation = true;
      if($(this).attr('data-confirm')){
        confirmation = confirm($(this).attr('data-confirm'));
      }

      if(confirmation){ 
        var f = document.createElement('form'); 
        f.style.display = 'none'; 
        this.parentNode.appendChild(f); 
        f.method = 'POST'; 
        f.action = this.href;
        var m = document.createElement('input'); 
        m.setAttribute('type', 'hidden'); 
        m.setAttribute('name', '_method');
        m.setAttribute('value', $(this).attr("data-method")); 
        f.appendChild(m);
        var s = document.createElement('input'); 
        s.setAttribute('type', 'hidden'); 
        s.setAttribute('name', 'authenticity_token'); 
        s.setAttribute('value', $('meta[name=csrf-token]').attr('content')); 
        f.appendChild(s);
        f.submit(); 
      };

      return false;
    });
  }
}

