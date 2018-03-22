// inject bundled Elm app into div#main
var Elm = require( '../elm/Main' );
var is_js = require('../../node_modules/is_js/is.min.js');

function logLocalStorage() {
  console.warn(localStorage);
}

function resetLocalStorage() {
  localStorage.removeItem('userName');
  localStorage.removeItem('accessKeyId');
  localStorage.removeItem('secretAccessKey');
  localStorage.removeItem('token');
  localStorage.removeItem('ec2Url');
  localStorage.removeItem('ec2Region');
}

function getStoredAuthData() {
  logLocalStorage();
  var storedUserNameInput = localStorage.getItem('userName');
  var storedAccessKeyIdInput = localStorage.getItem('accessKeyId');
  var storedSecretAccessKeyInput = localStorage.getItem('secretAccessKey');
  var storedToken = localStorage.getItem('token');
  var storedEc2Url = localStorage.getItem('ec2Url');
  var storedEc2Region = localStorage.getItem('ec2Region');

  return storedUserNameInput
    && storedAccessKeyIdInput
    && storedSecretAccessKeyInput
    && storedToken
    ? ({
      userName: storedUserNameInput,
      accessKeyId: storedAccessKeyIdInput,
      secretAccessKey: storedSecretAccessKeyInput,
      token: storedToken,
      ec2Url: storedEc2Url ? storedEc2Url : "",
      ec2Region: storedEc2Region ? storedEc2Region : ""
    }) : null;
}

function getCreateContainerRequestBody(elmApp, port, name, image, bindings, binds, privileged, openStdin, tty) {
  //TODO: verify object structure
  if (!is_js.all.existy(name, image, bindings, binds, privileged, openStdin, tty)) {
    return elmApp.ports[port].send("Error some arguments are undefined");
  }

  var data = {
    "name": name,
    "Image": image,
    "ExposedPorts": {},
    "HostConfig": {
      "PortBindings": {},
      "Binds": binds,
      "NetworkMode": "bridge",
      "Privileged": privileged
    },
    "Volumes": {},
    "OpenStdin": openStdin,
    "Tty": tty
  };

  var {exposedPorts, portBindings} = bindings.reduce(function(acc, {container, host}) {
    acc["exposedPorts"][container] = {};

    var hostPort = {
      "HostPort": host
    };

    if (is_js.existy(acc["portBindings"][container])) {
      acc["portBindings"][container].push(hostPort);
    } else {
      acc["portBindings"][container] = [hostPort];
    }

    return acc;
  }, {
    exposedPorts: {},
    portBindings: {}
  });

  data["ExposedPorts"] = exposedPorts;
  data["HostConfig"]["PortBindings"] = portBindings;

  elmApp.ports[port].send(data);
}

function reformatContainerValue(elmApp, port, unformattedContainer) {
  if (!is_js.all.existy(unformattedContainer, unformattedContainer.container)) {
    return elmApp.ports[port].send("Error some arguments are undefined");
  }

  const container = unformattedContainer.container;

  container['Names'] = [container['Name']];
  container['ImageID'] = container['Image'];
  container['Command'] = container['Config']['Cmd'].join(' ');
  container['Status'] = container['State']['Status'];
  container['Privileged'] = `${container['HostConfig']['Privileged']}`;
  container['Created'] = isNaN(Date.parse(container['Created'])) ? -1 : Date.parse(container['Created']);

  elmApp.ports[port].send({container});
}

function setupElmPorts(elmApp) {
  elmApp.ports.saveCreds.subscribe(function({userName, accessKeyId, secretAccessKey, token}) {
    if (!is_js.all.existy(userName, accessKeyId, secretAccessKey, token)) {
      return console.Error("saveCreds port some arguments are undefined");
    }
    console.warn("JS got msg from Elm: saveCreds", userName, accessKeyId, secretAccessKey, token);
    localStorage.setItem('userName', userName);
    localStorage.setItem('accessKeyId', accessKeyId);
    localStorage.setItem('secretAccessKey', secretAccessKey);
    localStorage.setItem('token', token);
  });

  elmApp.ports.saveEc2Url.subscribe(function(url) {
    if (!is_js.existy(url)) {
      return console.Error("saveEc2Url port some arguments are undefined");
    }
    localStorage.setItem('ec2Url', url);
  });

  elmApp.ports.saveEc2Region.subscribe(function(region) {
    if (!is_js.existy(region)) {
      return console.Error("saveEc2Url port some arguments are undefined");
    }
    localStorage.setItem('ec2Region', region);
  });

  elmApp.ports.logout.subscribe(function() {
    console.warn("JS got msg from Elm: logout");
    resetLocalStorage();
  });

  elmApp.ports.getCreateContainerRequestBody.subscribe(function({name, image, bindings, binds, privileged, openStdin, tty}) {
    getCreateContainerRequestBody(elmApp, 'createContainerRequestBody', name, image, bindings, binds, privileged, openStdin, tty);
  });

  elmApp.ports.reformatContainerValue.subscribe(function(container) {
    console.warn(container);
    reformatContainerValue(elmApp, 'formatedContainerValue', container);
  });
}

var elmApp = Elm.Main.fullscreen(getStoredAuthData());
setupElmPorts(elmApp);