import axios from '@/libs/api.request'

export const getBankData = () => {
  return axios.request({
    url: 'api/thirdParty/listBank',
    method: 'get'
  })
}
