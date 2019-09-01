import requests
from aliyun_ecs_to_jumpserver import ali_get_ecs_list


# MFA
# def get_jumpserver_token(base_url, username, password, otp_code):
#     post_data = {"username": username, "password": password}
#     url = base_url + "/api/users/v1/auth/"
#     req = requests.post(url, data=post_data)
#     response = req.json()
#     seed = response.get('seed')
#     otp_url = base_url + response.get('otp_url')
#     post_data2 = {"seed": seed, "otp_code": otp_code}
#     req2 = requests.post(otp_url, data=post_data2)
#     token = req2.json()['token']
#     authorization = 'Bearer' + ' ' + token
#     print(authorization)
#     return authorization

def get_jumpserver_token(base_url, username, password):
    post_data = {"username": username, "password": password}
    url = base_url + "/api/users/v1/auth/"
    req = requests.post(url, data=post_data)
    token = req.json()['token']
    authorization = 'Bearer' + ' ' + token
    return authorization

def get_asset_ids(base_url, token):
    authorization = {"Authorization": token}
    url = base_url + "/api/assets/v1/assets/"
    offset = 0
    count = 1
    assets_ip = []
    while True:
        payload = {"limit": 10, "offset": offset}
        req = requests.get(url, headers=authorization, params=payload)
        res = req.json()
        for i in res["results"]:
            # asset = {str(i['hostname']): [i['id'],i['ip'], i['public_ip']]}
            # asset_list.update(asset)
            asset_ip = i['ip']
            assets_ip.append(asset_ip)
        if offset == 0:
            asset_count = res['count']
        if count > asset_count / 10:
            break
        offset += 10
        count += 1
    return assets_ip

def cmp_ali_jumpserver(ecs_lists, jumpserver_assets_ip):
    asset_need_add = []
    for ecs in ecs_lists:
        if ecs.get('ip') not in jumpserver_assets_ip:
            asset_need_add.append(ecs)
    return asset_need_add

def add_asset(base_url, asset_neet_add, token):
    authorization = {"Authorization": token}
    url = base_url + '/api/assets/v1/assets/'
    for asset in asset_neet_add:
        print(asset)
        req = requests.post(url, headers=authorization, json=asset)
        if req.status_code == 200 or req.status_code == 201:
            print('sucess')
        else:
            print(req.status_code)
            info = req.content.decode('utf8')
            print(info)

if __name__ == '__main__':
    username = "xxxx"
    password = "xxxx"
    base_url = "http://xxxxx:xx"
    # MFA
    # otp_code = '070156'
    # token = get_jumpserver_token(base_url, username, password, otp_code)
    token = get_jumpserver_token(base_url, username, password)
    asset_list = get_asset_ids(base_url, token)
    print(asset_list)
    ecs_lists = list(ali_get_ecs_list.list_instance())
    asset_need_add = cmp_ali_jumpserver(ecs_lists, asset_list)
    add_asset(base_url, asset_need_add, token)