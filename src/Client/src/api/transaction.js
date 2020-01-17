import axios from '@/libs/api.request'

export const getTransactionData = () => {
  return axios.request({
    url: 'api/transaction/list',
    method: 'get'
  })
}

export const TransactionWithNewReceipt = ({seller, amount, time, deadline, info}) => {
  const data = {
    seller,
    amount,
    time,
    deadline,
    info
  }
  return axios.request({
    url: 'api/transaction/createNewReceipt',
    data,
    method: 'post'
  })
}

export const TransactionByTransferReceipt = ({seller, amount, time, receiptId, info}) => {
  const data = {
    seller,
    amount,
    time,
    receiptId,
    info
  }
  return axios.request({
    url: 'api/transaction/transferReceipt',
    data,
    method: 'post'
  })
}
