import json
from aliyunsdkecs.request.v20140526.DescribeRegionsRequest import DescribeRegionsRequest
from aliyunsdkecs.request.v20140526.DescribeInstancesRequest import DescribeInstancesRequest
from aliyunsdkcore import client


def list_region():
	request = DescribeRegionsRequest()
	response = _send_request(request)
	if response is not None:
		region_list = response.get('Regions').get('Region')
		result = map(_print_region_id, region_list)
		return result

def list_instance():
	request = DescribeInstancesRequest()
	request.set_PageSize(100)
	request.set_PageNumber(1)
	response = _send_request(request)
	if response is not None:
		instance_list = response.get('Instances').get('Instance')
		result = map(_print_instance_info, instance_list)
		return result

def _send_request(request):
	request.set_accept_format('json')
	request_str = clt.do_action_with_exception(request)
	request_detail = json.loads(request_str)
	return request_detail

def _print_region_id(item):
	region_id = item.get('RegionId')
	return region_id

def _print_instance_info(item):
	eip = item.get('EipAddress').get('IpAddress')
	public_ip = '' if item.get('PublicIpAddress').get('IpAddress') == [] else item.get('PublicIpAddress').get('IpAddress')[0]
	vpc_private_ip = '' if item.get('VpcAttributes').get('PrivateIpAddress').get('IpAddress') == [] else item.get('VpcAttributes').get('PrivateIpAddress').get('IpAddress')[0]
	inner_ip = '' if item.get('InnerIpAddress').get('IpAddress') == [] else  item.get('InnerIpAddress').get('IpAddress')[0]
	in_ip = vpc_private_ip + inner_ip
	pub_ip = eip + public_ip

	data = {
		'nodes': ['xxxxxxxxxxxxxx',],
		'is_active': 'true',
		'protocols': ['ssh/22'],
		'hostname': item.get('InstanceName'),
		'public_ip': pub_ip,
		'ip': in_ip,
		'sn': item.get('SerialNumber'),
		'admin_user': 'xxxxxxxxxxxxx'
	}
	return data


key = 'xxxxxxxxx'
secret = 'xxxxxxxxx'
# clt = client.AcsClient(key, secret, 'cn-hongkong')
clt = client.AcsClient(key, secret, 'us-west-1')
# print(list(list_instance()))
# regions = list(list_region())
# for region in regions:
# 	clt = client.AcsClient(key, secret, region)
# 	if list(list_instance()) != []:
# 		print(region)
