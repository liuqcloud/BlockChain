import axios from '@/libs/api.request'

export const getAllEnterprises = () => {
  return axios.request({
    url: 'api/enterprise/list',
    method: 'get'
  })
}

export const coreEnterpriseIdentifiy = ({address}) => {
  const data = {
    address,
  }
  return axios.request({
    url: 'api/enterprise/coreEnterpriseIdentifiy',
    data,
    method: 'post'
  })
}
