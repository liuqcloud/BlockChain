import axios from '@/libs/api.request'

export const getAllfinanceApply = () => {
  return axios.request({
    url: 'api/financeApply/list',
    method: 'get'
  })
}

export const addApply = ({receiptId, bankAddr, amount, date}) => {
  const data = {
    receiptId,
    bankAddr,
    amount,
    date
  }
  return axios.request({
    url: 'api/financeApply/add',
    data,
    method: 'post'
  })
}
