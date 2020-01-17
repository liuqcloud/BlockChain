import axios from '@/libs/api.request'

export const registerEnterprise = ({ name, properties }) => {
  const data = {
    name,
    properties
  }
  return axios.request({
    url: 'api/user/registerEnterprise',
    data,
    method: 'post'
  })
}

export const registerThirdParty = ({ name, type }) => {
  const data = {
    name,
    type
  }
  return axios.request({
    url: 'api/user/registerThirdParty',
    data,
    method: 'post'
  })
}

export const getUserDetail = () => {
  return axios.request({
    url: 'api/user/detail',
    method: 'get'
  })
}
