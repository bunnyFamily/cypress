import _ from 'lodash'
import { computed, observable, action } from 'mobx'
import Project from '../project/project-model'

class Projects {
  @observable projects = []
  @observable error = null
  @observable isLoading = false
  @observable _membershipRequestedIds = {}

  @computed get chosen () {
    return _.find(this.projects, { isChosen: true })
  }

  @computed get other () {
    return _.filter(this.projects, (project) => !project.isChosen)
  }

  @computed get clientProjects () {
    return _.map(this.projects, (project) => _.pick(project, ['path', 'id']))
  }

  @action getProjectByPath (path) {
    if (!this.projects.length) {
      return this.addProject()
    }

    return _.find(this.projects, { path })
  }

  @action addProject (path) {
    const project = new Project({ path })
    this.projects.push(project)
    this._saveToLocalStorage()
    return project
  }

  @action setLoading (isLoading) {
    this.isLoading = isLoading
  }

  @action setProjects (projects) {
    // get the projects off of localStorage (with statuses)
    // and set them up so we don't have to wait for data from server
    const localProjects = JSON.parse(localStorage.getItem('projects') || '[]')
    // index for quick lookup
    const localProjectsIndex = _.keyBy(localProjects, 'id')

    this.projects = _.map(projects, (project) => {
      const props = _.extend(project, localProjectsIndex[project.id])
      return new Project(props)
    })
  }

  @action setProjectStatuses (projects) {
    // index for quick lookup
    const projectsIndex = _.keyBy(projects, 'id')

    // merge projects received from api with what we
    // already have in memory
    _.each(this.projects, (project) => {
      project.update(projectsIndex[project.id])
    })

    this._saveToLocalStorage()
  }

  @action setError (err) {
    this.error = err
  }

  setChosen (project) {
    this.error = null
    _.each(this.projects, (project) => {
      project.isChosen = false
    })
    project.isChosen = true
  }

  updateProject (project, props) {
    project.update(props)
    this._saveToLocalStorage()
  }

  @action removeProject ({ path }) {
    const projectIndex = _.findIndex(this.projects, { path })

    if (projectIndex != null) {
      this.projects.splice(projectIndex, 1)
      this._saveToLocalStorage()
    }
  }

  serializeProjects () {
    return _.map(this.projects, (project) => project.serialize())
  }

  _saveToLocalStorage () {
    localStorage.setItem('projects', JSON.stringify(this.serializeProjects()))
  }

  membershipRequested (id) {
    this._membershipRequestedIds[id] = true
  }

  wasMembershipRequested (id) {
    return this._membershipRequestedIds[id] === true
  }
}

export default new Projects()
