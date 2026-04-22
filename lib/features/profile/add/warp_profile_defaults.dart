const defaultWarpProfileName = 'POKROV WARP';
const defaultWarpProfileUrl = String.fromEnvironment(
  'PORTAL_WARP_DEFAULTS_URL',
);
const defaultWarpProfileContent = '''
//profile-title: base64:UE9LUk9WIFdBUlA=
//profile-update-interval: 24
//subscription-userinfo: upload=0; download=0; total=10737418240000000; expire=2546249531
//support-url: https://t.me/pokrov_supportbot
//profile-web-page-url: https://pokrov.space/

psiphon://auto/
warp://A1@188.114.97.170:894#warp_in_warp -> warp://A2@188.114.97.170:894?ifp=40-80&ifps=40-100&ifpd=4-8&ifpm=m4#m4
warp://B1@auto#WarpInWarp -> warp://B2@auto?ifpm=m4#LocalIP
''';
const defaultCnWarpProfileContent =
    '#profile-title: POKROV WARP\nwarp://p1@auto#National&&detour=warp://p2@auto#WoW';
