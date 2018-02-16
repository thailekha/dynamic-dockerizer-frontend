// inject bundled Elm app into div#main
var Elm = require( '../elm/Main' );
var is_js = require('../../node_modules/is_js/is.min.js');
var request = require('../../node_modules/superagent/superagent.js');

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

function sendReqCreateContainer(elmApp, port, name, image, bindings, binds, privileged, openStdin, tty) {
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

  request
    .post('http://localhost:3001/api/containers/create')
    .send(data)
    .set('accept', 'json')
    .end((err, res) => {
      console.warn(err);
      console.warn(res);
      if (err) {
        return elmApp.ports[port].send({
          statusCode: res.statusCode,
          success: false,
          message: is_js.existy(res.body) ? JSON.stringify(res.body) : "Error request create container"
        });
      }
      elmApp.ports[port].send({
        statusCode: res.statusCode,
        success: true,
        message: "",
        body: res.body.message
      });
    });
}

function sendReqContainers(elmApp, port) {
  request
    .get('http://localhost:3001/api/containers/all')
    .set('accept', 'json')
    .end((err, res) => {
      console.warn(err);
      console.warn(res);
      if (err) {
        return elmApp.ports[port].send({
          statusCode: res.statusCode,
          succes: false,
          message: is_js.existy(res.body) ? JSON.stringify(res.body) : "Error request all containers"
        });
      }

      const dataForElm = res.body.containers.map(c => {
        c['Created'] = c['Created'] + '';
        c['Privileged'] = "unknown";
        return c;
      });

      elmApp.ports[port].send({
        statusCode: res.statusCode,
        success: true,
        message: "",
        containers: dataForElm
      });
    });
}

function sendReqContainer(elmApp, port, containerID) {
  if (!is_js.all.existy(containerID)) {
    return elmApp.ports[port].send("Error some arguments are undefined");
  }

  request
    .get(`http://localhost:3001/api/containers/${containerID}`)
    .set('accept', 'json')
    .end((err, res) => {
      console.warn(err);
      console.warn(res);
      if (err) {
        return elmApp.ports[port].send({
          statusCode: res.statusCode,
          succes: false,
          message: is_js.existy(res.body) ? JSON.stringify(res.body) : "Error request all containers"
        });
      }

      const dataForElm = res.body.container;

      dataForElm['Names'] = [dataForElm['Name']];
      dataForElm['ImageID'] = dataForElm['Image'];
      dataForElm['Command'] = dataForElm['Config']['Cmd'].join(' ');
      dataForElm['Status'] = dataForElm['State']['Status'];
      dataForElm['Privileged'] = dataForElm['HostConfig']['Privileged'] + '';

      elmApp.ports[port].send({
        statusCode: res.statusCode,
        success: true,
        message: "",
        container: dataForElm
      });
    });
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

  elmApp.ports.reqCreateContainer.subscribe(function({name, image, bindings, binds, privileged, openStdin, tty}) {
    sendReqCreateContainer(elmApp, 'onCreateContainerResponse', name, image, bindings, binds, privileged, openStdin, tty);
  });

  elmApp.ports.reqContainers.subscribe(function() {
    sendReqContainers(elmApp, 'onContainersResponse');
  });

  elmApp.ports.reqContainer.subscribe(function(containerID) {
    sendReqContainer(elmApp, 'onContainerResponse', containerID);
  });
}

var elmApp = Elm.Main.fullscreen(getStoredAuthData());
setupElmPorts(elmApp);