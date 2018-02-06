// inject bundled Elm app into div#main
var Elm = require( '../elm/Main' );

function logLocalStorage() {
  console.warn(localStorage);
}

function resetLocalStorage() {
  localStorage.removeItem('userName');
  localStorage.removeItem('accessKeyId');
  localStorage.removeItem('secretAccessKey');
}

function getStoredAuthData() {
  logLocalStorage();
  var storedUserNameInput = localStorage.getItem('userName');
  var storedAccessKeyIdInput = localStorage.getItem('accessKeyId');
  var storedSecretAccessKeyInput = localStorage.getItem('secretAccessKey');

  return storedUserNameInput
    && storedAccessKeyIdInput
    && storedSecretAccessKeyInput
    ? ({
      userName: storedUserNameInput,
      accessKeyId: storedAccessKeyIdInput,
      secretAccessKey: storedSecretAccessKeyInput,
    }) : null;
}

function setupElmPorts(elmApp) {
  elmApp.ports.saveCreds.subscribe(function({userName, accessKeyId, secretAccessKey}) {
    console.warn("JS got msg from Elm: saveCreds", userName, accessKeyId, secretAccessKey);
    localStorage.setItem('userName', userName);
    localStorage.setItem('accessKeyId', accessKeyId);
    localStorage.setItem('secretAccessKey', secretAccessKey);
  });

  elmApp.ports.logout.subscribe(function() {
    console.warn("JS got msg from Elm: logout");
    resetLocalStorage();
  });
}

var elmApp = Elm.Main.fullscreen(getStoredAuthData());
setupElmPorts(elmApp);