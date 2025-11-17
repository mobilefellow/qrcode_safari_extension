"use strict";

var QR_SIZE = 600;
var fore_bg = '#000000';
var back_bg = '#ffffff';
var img_size = 300;
var is_transparnet_bg = true;
var web_url;

var isMockEnvironment = (browser.runtime.sendNativeMessage == null);
var mockEnabled = true;
var mockAllFavoritesResponse = {
  "allItems": [{
    "text": "https://chat.aiwiz.xyz/zh"
  }, {
    "alias": "2",
    "text": "https://developer.apple.com/documentation/swiftui/environmentvalues/calendar"
  }, {
    "alias": "3",
    "text": "https://swiftwithmajid.com/2021/10/21/mastering-controlgroup-in-swiftui/https://swiftwithmajid.com/2021/10/21/mastering-controlgroup-in-swiftui/https://swiftwithmajid.com/2021/10/21/mastering-controlgroup-in-swiftui/"
  }, {
    "alias": "4",
    "text": "https://swiftwithmajid.com/2021/10/21/mastering-controlgroup-in-swiftui/"
  }, {
    "text": "https://swiftwithmajid.com/2021/10/21/mastering-controlgroup-in-swiftui/"
  }
  ]
};

$(document).ready(function () {
  console.log("Hello World!", browser);

  fetchWebUrl();
  renderQRHandler();
  fetchAllFavorites();

  $('#qrcode-href').on('input', function () {
    var inputText = $(this).val();
    console.log('Textarea input changed:', inputText);
    renderQRHandler();
  });

  $("#addFavoriteButton").on("click", function () {
    onAddFavorite();
  });
});

function onAddFavorite() {
  console.log('onAddFavorite');
  var href = $("#qrcode-href").val();
  let message = {
    'action': 'addFavorite',
    'text': href,
    // 'alias': "345"
  }
  let callback = function (response) {
    console.log("Received sendNativeMessage response:");
    console.log(response);
    renderFavoriteList(response.allItems);
  };

  if (isMockEnvironment) {
    if (mockEnabled) {
      mockAllFavoritesResponse.allItems.push({
        "text": href 
      })
      callback(mockAllFavoritesResponse);
    }
    return; 
  }

  browser.runtime.sendNativeMessage("com.swang.qrcode.Extension", message, callback);
}

function onDeleteFavorite(text, index) {
  console.log('deleteFavorite');
  let message = {
    'action': 'deleteFavorite',
    'text': text,
    'index': index,
  }
  let callback = function (response) {
    console.log("Received sendNativeMessage response:");
    console.log(response);
    renderFavoriteList(response.allItems);
  };

  if (isMockEnvironment) { 
    if (mockEnabled) {
      mockAllFavoritesResponse.allItems.splice(index, 1);
      callback(mockAllFavoritesResponse);
    }
    return; 
  }

  browser.runtime.sendNativeMessage("com.swang.qrcode.Extension", message, callback);
}

function onUpdateFavoriteAlias(text, alias, index) {
  console.log('updateFavoriteAlias');
  let message = {
    'action': 'updateFavoriteAlias',
    'text': text,
    'alias': alias,
    'index': index,
  }
  let callback = function (response) {
    console.log("Received sendNativeMessage response:");
    console.log(response);
    // renderFavoriteList(response.allItems);
  };

  browser.runtime.sendNativeMessage("com.swang.qrcode.Extension", message, callback);
}

function isValid(obj) {
  return obj != undefined && obj != null;
}

async function fetchWebUrl() {
  if (isValid(browser.tabs)) {
    let currentTab = await browser.tabs.getCurrent();
    if (isValid(currentTab)) {
      web_url = currentTab.url;
    }
  } else {
    if (mockEnabled) {
      web_url = "https://www.baidu.com/mock"
    }
  }

  if (isValid(web_url)) {
    $('#qrcode-href').val(web_url);
    renderQRHandler();
  }
}

function fetchAllFavorites() {
  console.log('fetchAllFavorites');
  let callback = function (response) {
    console.log("Received sendNativeMessage response:");
    console.log(response);
    renderFavoriteList(response.allItems);
  };

  if (isMockEnvironment) { 
    if (mockEnabled) {
      callback(mockAllFavoritesResponse);
    }
    return; 
  }

  let message = {
    'action': 'fetchAllFavorites'
  }
  browser.runtime.sendNativeMessage("com.swang.qrcode.Extension", message, callback);
}

function renderFavoriteList(allItems) {
  if (!isValid(allItems) || Array.isArray(allItems) == false) {
    return;
  }
  const listContainer = $("#favorite-list");
  listContainer.empty();
  for (let index = allItems.length - 1; index >= 0; index--) {
    const item = allItems[index];
    // Create list item
    const listItem = $("<div></div>", {
      class: 'favorite-item'
    });

    // Create favorite button
    const favoriteButton = $("<button/>", {
      class: 'favorite-button'
    });
    const favoriteIcon = $("<img/>", {
      class: 'favorite-icon',
      src: 'images/favorite-48.png',
      alt: 'Favorite',
    });
    favoriteButton.append(favoriteIcon);
    favoriteButton.on("click", function () {
      onDeleteFavorite(item.text, index);
    });
    listItem.append(favoriteButton);

    // Create text container
    const textContainer = renderFavoriteItemTextContainer(item, index);
    listItem.append(textContainer);

    listContainer.append(listItem);
  };
}

function renderFavoriteItemTextContainer(item, index) {
  // text container
  const textContainer = $("<span></span>", {
    class: 'favorite-text-container'
  });
  textContainer.on("click", function () {
    console.log(`Item ${item.text} clicked!`);
    $('#qrcode-href').val(item.text)
    renderQRHandler();
  });

  // text container - text
  if (item.text && item.text.length > 0) {
    const element = $("<div></div>", {
      class: 'favorite-text'
    }).text(item.text);
    textContainer.append(element);
  }

  // text container - alias
  const aliasTextField = $("<input>").attr({
    type: "text",
    placeholder: "Add alias"
  });
  if (item.alias && item.alias.length > 0) {
    aliasTextField.val(item.alias);
  }
  const updateAliasTextFieldClass = function () {
    var isEmpty = aliasTextField.val().trim() == "";
    aliasTextField.removeClass();
    if (!isEmpty) {
      aliasTextField.addClass("favorite-alias");
    } else {
      aliasTextField.addClass("favorite-alias-empty");
    }
  };
  updateAliasTextFieldClass();

  aliasTextField.on("input", function() {
    updateAliasTextFieldClass();
    // save input the native
    onUpdateFavoriteAlias(item.text, aliasTextField.val().trim(), index);
  });
  textContainer.append(aliasTextField);
  
  return textContainer;
}


function renderQRHandler() {
  var href = $("#qrcode-href").val();
  var $qrcode_img = $('#qrcode-img');
  $qrcode_img.html('');
  renderQR($qrcode_img, img_size, href);
  // updateImgHref();
}

function renderQR($el, the_size, the_text) {
  var quiet = '1';
  if (back_bg != '#ffffff') {
    quiet = '1';
  }
  if (is_transparnet_bg) {
    back_bg = null;
  }
  $el.qrcode(qrObjectBuilder(the_size, fore_bg, the_text, back_bg, quiet));
  $('#qrcode-img-buffer').empty().qrcode(qrObjectBuilder(the_size, fore_bg, the_text, back_bg, 1, true));
}

function qrObjectBuilder(s, f, t, b, q, c) {
  var r = 'image';
  if (c) {
    r = 'canvas';
  }
  var o = {
    'render': r,
    size: s,
    fill: f,
    text: t,
    background: b,
    'quiet': q
  }
  o.ecLevel = 'L';
  return o;
}

// function updateImgHref() {
//   var link = $("#export")[0];
//   link.download = 'exported_qrcode_image_'+img_size+'.png';
//   link.href = $('#qrcode-img-buffer > canvas')[0].toDataURL();
// }
