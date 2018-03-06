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

function sendReqCreateContainer(elmApp, port, url, token, name, image, bindings, binds, privileged, openStdin, tty) {
  //TODO: verify object structure
  if (!is_js.all.existy(url, token, name, image, bindings, binds, privileged, openStdin, tty)) {
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
    .post(`${url}/api/containers/create`)
    .send(data)
    .set('accept', 'json')
    .set('Authorization', `Bearer ${token}`)
    .end((err, res) => {
      console.warn(err);
      console.warn(res);
      if (err) {
        return elmApp.ports[port].send({
          statusCode: (res && res.statusCode) ? res.statusCode : -1,
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

function sendReqContainers(elmApp, port, url, token) {
  if (!is_js.all.existy(url, token)) {
    return elmApp.ports[port].send("Error some arguments are undefined");
  }

  request
    .get(`${url}/api/containers/all`)
    .set('accept', 'json')
    .set('Authorization', `Bearer ${token}`)
    .end((err, res) => {
      console.warn(err);
      console.warn(res);
      if (err) {
        return elmApp.ports[port].send({
          statusCode: (res && res.statusCode) ? res.statusCode : -1,
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

function sendReqContainer(elmApp, port, url, token, containerID) {
  if (!is_js.all.existy(url, token, containerID)) {
    return elmApp.ports[port].send("Error some arguments are undefined");
  }

  request
    .get(`${url}/api/containers/${containerID}`)
    .set('accept', 'json')
    .set('Authorization', `Bearer ${token}`)
    .end((err, res) => {
      console.warn(err);
      console.warn(res);
      if (err) {
        return elmApp.ports[port].send({
          statusCode: (res && res.statusCode) ? res.statusCode : -1,
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

  elmApp.ports.reqCreateContainer.subscribe(function({url, token, name, image, bindings, binds, privileged, openStdin, tty}) {
    sendReqCreateContainer(elmApp, 'onCreateContainerResponse', url, token, name, image, bindings, binds, privileged, openStdin, tty);
  });

  elmApp.ports.reqContainers.subscribe(function({url, token}) {
    sendReqContainers(elmApp, 'onContainersResponse', url, token);
  });

  elmApp.ports.reqContainer.subscribe(function({url, token, containerID}) {
    sendReqContainer(elmApp, 'onContainerResponse', url, token, containerID);
  });
}

var elmApp = Elm.Main.fullscreen(getStoredAuthData());
setupElmPorts(elmApp);