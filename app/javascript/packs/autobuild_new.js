import $ from "jquery";
import axios from 'axios';

function selectOptionsFactory(text, value) {
  let option = document.createElement('option')
  option.value = value;
  option.innerHTML = text
  return option
}

// TODO: Refactor and move away from jquery eventually
function buildRuleFactory(index) {
  let template = `<tr>
    <td><select class="form-select" name="autobuild[rules[${index}][source_type]]" id="autobuild_rules[${index}][source_type]"><option value="branch">Branch</option>
  <option value="tag">Tag</option></select></td>
    <td><input value="master" placeholder="master" class="form-control" type="text" name="autobuild[rules[${index}][source]]" id="autobuild_rules[${index}][source]"></td>
    <td><input value="latest" placeholder="latest" class="form-control" type="text" name="autobuild[rules[${index}][docker_tag]]" id="autobuild_rules[${index}][docker_tag]"></td>
    <td><input value="Dockerfile" placeholder="Dockerfile" class="form-control" type="text" name="autobuild[rules[${index}][dockerfile]]" id="autobuild_rules[${index}][docker_tag]"></td>
    <td><input value="/" placeholder="/" class="form-control" type="text" name="autobuild[rules[${index}][build_context]]" id="autobuild_rules[${index}][build_context]"></td>
    <td><input name="autobuild[rules[${index}][autobuild]]" type="hidden" value="0"><input class="form-check-input align-middle" type="checkbox" value="1" checked="checked" name="autobuild[rules[${index}][autobuild]]" id="autobuild_rules[${index}][autobuild]"></td>
    <td><a class="btn btn-danger btn-sm" href="#">Delete</a></td>
  </tr>`

  return $.parseHTML(template)
}

// TODO: Refactor and move away from jquery eventually
function buildEnvVarFactory(index) {
  let template = `<tr>
    <td><input placeholder="DEBUG" class="form-control" type="text" name="autobuild[env_vars[${index}][key]]" id="autobuild_env_vars[${index}][key]"></td>
    <td><input placeholder="true" class="form-control" type="text" name="autobuild[env_vars[${index}][value]]" id="autobuild_env_vars[${index}][value]"></td>
    <td><a class="deleteBuildRule btn btn-danger btn-sm" href="#">Delete</a></td>
  </tr>`

  return $(template)
}

function showCodeRepoList(e, codeRepoType) {
  let linkedAppId = e.target.value;
  // TODO: Better way?
  if (linkedAppId.startsWith("Select")) {
    return
  }

  document.getElementById("newAutobuildOverlay").classList.remove("d-none")
  axios.get(`/linked_apps/${codeRepoType}/${linkedAppId}/repos`).then((resp) => {
    let codeRepoListContainer = document.getElementById("codeRepoListContainer")
    let codeRepoList = document.getElementById('autobuild_code_repo_name')
    while (codeRepoList.children.length != 1) {
      codeRepoList.removeChild(codeRepoList.lastChild)
    }
    resp.data.forEach((repoName) => {
      codeRepoList.appendChild(selectOptionsFactory(repoName, repoName))
    })
    codeRepoListContainer.classList.toggle('d-none')
    document.getElementById("newAutobuildOverlay").classList.add("d-none")
  })
}

// Github Linked Apps are not available in update screen
// So, this will fail unless we have an if statement
if (document.getElementById('autobuild_github_app')) {
  document.getElementById('autobuild_github_app').addEventListener('change', (e) => {
    showCodeRepoList(e, 'github')
  })
}

if (document.getElementById('autobuild_gitlab_app')) {
  document.getElementById('autobuild_gitlab_app').addEventListener('change', (e) => {
    showCodeRepoList(e, 'gitlab')
  })
}

// Github Linked Apps are not available in update screen
// So, this will fail unless we have an if statement
if (document.getElementById('autobuild_docker_registry')) {
  document.getElementById('autobuild_docker_registry').addEventListener('change', (e) => {
    let dockerhubId = e.target.value;
    axios.get(`/docker_registry/dockerhub/${dockerhubId}/repos`).then((resp) => {
      let dockerRepoListContainer = document.getElementById("dockerRepoListContainer")
      let githubRepoList = document.getElementById('autobuild_code_repo_name')
      resp.data.forEach((repoName) => {
        githubRepoList.appendChild(selectOptionsFactory(repoName, repoName))
      })
      dockerRepoListContainer.classList.toggle('d-none')
    })
  })
}

function removeBuildRuleListener(e) {
  let link = e.target
  // Only to be triggered when the link is clicked.
  // Not when the area outside the link is clicked.
  if (link.tagName == 'A') {
    link.parentElement.parentElement.remove()
    e.preventDefault()
  }
}

document.getElementById("addBuildRule").addEventListener('click', (e) => {
  let buildRuleContainer = document.getElementById('buildRulesContainer')
  let currentRuleCount = buildRuleContainer.getElementsByTagName('tr').length
  // TODO: Make this configurable
  if (currentRuleCount <= 10) {
    let rule = buildRuleFactory(currentRuleCount)[0]
    buildRuleContainer.appendChild(rule)
    rule.addEventListener('click', removeBuildRuleListener)
  }
  e.preventDefault()
})

// Needed for the first default rule
Array.from(document.getElementsByClassName('deleteBuildRule')).forEach((elem, i) => {
  elem.addEventListener('click', removeBuildRuleListener)
})

document.getElementById("addEnvVars").addEventListener('click', (e) => {
  let buildEnvVarContainer = document.getElementById('envVarsContainer')
  let currentRuleCount = buildEnvVarContainer.getElementsByTagName('tr').length
  // TODO: Make this configurable
  if (currentRuleCount <= 20) {
    let rule = buildEnvVarFactory(currentRuleCount)[0]
    buildEnvVarContainer.appendChild(rule)
    rule.addEventListener('click', removeBuildRuleListener)
  }
  e.preventDefault()
})

document.getElementById("autobuild_code_repo_type").addEventListener('change', (e) => {
  document.getElementById("autobuildGithubAppContainer").classList.add("d-none")
  document.getElementById("autobuildGitlabAppContainer").classList.add("d-none")
  document.getElementById("codeRepoListContainer").classList.add('d-none')
  const repoType = e.target.value;
  if (repoType === 'github') {
    document.getElementById("autobuildGithubAppContainer").classList.remove("d-none")
  } else if (repoType == 'gitlab') {
    document.getElementById("autobuildGitlabAppContainer").classList.remove("d-none")
  }
})

document.getElementById("dockerRegistryTypeContainer").addEventListener('change', (e) => {
  const repoType = e.target.value;
  if (repoType === 'dockerhub') {
    document.getElementById("dockerRegistryListContainer").classList.remove("d-none")
  }
})