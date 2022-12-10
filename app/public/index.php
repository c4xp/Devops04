<?php /* phpinfo(); die; */ ?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
html, body { background-color: #fff; color: #000; font-family: Helvetica, Arial, sans-serif; font-weight: 100; height: 100vh; margin: 0; }
.full-height { height: 100vh; }
.flex-center { align-items: center; display: flex; justify-content: center; }
.container { display: flex; justify-content: space-between; flex-direction: column; }
.position-ref { position: relative; }
.code { border-right: 2px solid; font-size: 26px; padding: 0 15px 0 15px; text-align: center; }
.message { font-size: 18px; text-align: center; padding: 10px; }
.greenish { color:#696; }
.redish { color:#dd8866; }
</style>
</head>
<body>
<div class="flex-center position-ref full-height">
<div class="container">
<?php
// show errors
error_reporting(E_ALL); ini_set('error_reporting', E_ALL); ini_set('display_errors', 1); ini_set('display_startup_errors', 1);

// start sessions
session_start();

define('DB_HOSTNAME', getenv('DB_HOST'));
define('DB_USERNAME', getenv('DB_USERNAME'));
define('DB_PASSWORD', getenv('DB_PASSWORD'));
define('DB_DATABASE', getenv('DB_DATABASE'));

define('MEMCACHED_SERVER', !empty(getenv('MEMCACHED_SERVER'))?getenv('MEMCACHED_SERVER'):'memcached');
define('MEMCACHED_PORT', !empty(getenv('MEMCACHED_PORT'))?getenv('MEMCACHED_PORT'):'11211');

define('REDIS_SERVER', !empty(getenv('REDIS_SERVER'))?getenv('REDIS_SERVER'):'redis');
define('REDIS_PORT', !empty(getenv('REDIS_PORT'))?getenv('REDIS_PORT'):'6379');

// mysql
define('DB_DSN', 'mysql:dbname='.DB_DATABASE.';host='.DB_HOSTNAME);
// sqlsrv
//define('DB_DSN', 'sqlsrv:server = tcp:'.DB_HOSTNAME.'; Database = '.DB_DATABASE);

class Setup {
    public $data = array();

    public function __construct() {}

    public function _is_valid($flag, $compare = true) {
        if ($flag == $compare) {
            return '<span class="greenish">'.var_export($flag,1).'</span>';
        }
        return '<span class="redish">'.var_export($flag,1).'</span>';
    }

    public function formatBytes($size, $precision = 2) {
        $base = log($size, 1024);
        $suffixes = array('', 'K', 'M', 'G', 'T');   
        return round(pow(1024, $base - floor($base)), $precision) .' '. $suffixes[floor($base)];
    }

    public function detect() {
        // session
        $tmp = '';
        $valid = '';
        if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) { $valid = $_SERVER['HTTP_X_FORWARDED_FOR']; }
        if (empty($_SESSION['csrf'])) { $_SESSION['csrf'] = md5(openssl_random_pseudo_bytes(32)); }
        $this->data['php'] = 'php ver: '.PHP_VERSION.', host: '.$_SERVER['HOSTNAME'].', addr: '.$_SERVER['SERVER_ADDR'].', session: '.$_SESSION['csrf'].', fwd4: '.$valid;

        // openssl
        $rndstr = base64_encode(openssl_random_pseudo_bytes(32));
        $hash_algos = array_values(hash_algos());
        $vips_hash_algos = array();
        if (is_array($hash_algos) && count($hash_algos) > 0) { foreach($hash_algos as $a) { if ($a == 'md5' || $a == 'ripemd160' || $a == 'sha256' || $a == 'sha3-512') { $vips_hash_algos[] = $a; } } }

        $this->data['openssl'] = 'openssl enabled: '.$this->_is_valid(extension_loaded('openssl')).', '.
        'algos: '.$this->_is_valid(join(',',$vips_hash_algos), 'md5,sha256,sha3-512,ripemd160').",<br>\n".
        'random test: <span id="rndstr" class="greenish">'.$rndstr.'</span>';

        // image processing
        $tmp = $_SERVER['DOCUMENT_ROOT'].'/image3.jpg';
        $attr = getimagesize($tmp);
        $exif = exif_read_data($tmp);
        $this->data['image'] = 'gd enabled: '.$this->_is_valid(extension_loaded('gd')).', exif enabled: '.$this->_is_valid(extension_loaded('exif')).', imagick: '.$this->_is_valid(extension_loaded('imagick')).', mime test: '.$attr['mime'].', exif orientation: '.$this->_is_valid($exif['Orientation'], 3);

        // password hashing
        $pswdrnd = password_hash($rndstr, PASSWORD_DEFAULT);
        $pswdinf = password_get_info($pswdrnd);
        $this->data['password'] = 'algorithm detected: '.$pswdinf['algoName'].', hash test: '.$this->_is_valid(password_verify($rndstr, $pswdrnd));

        // opcache
        $tmp = '';
        $opcache_status = opcache_get_status();
        $tmp = $opcache_status['memory_usage']['used_memory'] + $opcache_status['memory_usage']['free_memory'];
        $this->data['opcache'] = 'opcache enabled: '.$this->_is_valid(extension_loaded('Zend OPcache')).', memory usage: '.$this->formatBytes($opcache_status['memory_usage']['used_memory'],1).'/'.$this->formatBytes($tmp,1);

        // memcached
        $tmp = '';
        $valid = '0';
        if (extension_loaded('memcached')) {
            $memcached = new Memcached();
            $memcached->addServer(MEMCACHED_SERVER, MEMCACHED_PORT);
            $tmp = sha1(time());
            $memcached->set('testkey', $tmp, 10);
            $valid = $memcached->get('testkey');
        }
        $this->data['memcached'] = 'memcached enabled: '.$this->_is_valid(extension_loaded('memcached')).', connection: '.MEMCACHED_SERVER.':'.MEMCACHED_PORT.' '.$this->_is_valid($valid == $tmp);

        // redis
        $tmp = '';
        $valid = '~';
        $inforedis = class_exists('Redis') ? phpversion('redis') : 'Not loaded';
        if (extension_loaded('redis')) {
            $redis = new Redis();
            $redis->connect(REDIS_SERVER, REDIS_PORT);
            $valid = $redis->ping();
        }
        $this->data['redis'] = 'redis enabled: '.$this->_is_valid(extension_loaded('redis')).', ver: '.$inforedis.', ping: '.$valid;

        // mysql
        $options = array(
            PDO::ATTR_PERSISTENT => true,
            PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8',
            PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => false,
        );
        if (defined('MYSQL_SSL_CA')) {
            $options[PDO::MYSQL_ATTR_SSL_CA] = getenv('MYSQL_SSL_CA');
        }
        $tmp = array();
        $conn = new PDO(DB_DSN, DB_USERNAME, DB_PASSWORD, $options);
        $result = $conn->query('SHOW TABLES');
        foreach ($result as $r) {
            $tmp[] = $r[0];
        }
        $this->data['mysql'] = 'mysql enabled: '.$this->_is_valid(extension_loaded('pdo_mysql')).', connection: '.DB_DSN.', tables: '.count($tmp);
        $conn = null;
    }

    public function display() {
        foreach($this->data as $i => $k) {
            echo "<p>".$k."</p>\n";
        }
    }

    public function run() {
        $this->detect();
        $this->display();
    }
}

$setup = new Setup();
$setup->run();
?>
</div>
</div>
</body>    
</html>