// Run unit tests before accepting change on Gerrit.

node('phpbrew') {
  withPhp('7.0.26') {
	stage('Checkout from git') {
      checkout scm
  	}

	stage('Install dependencies') {
	  sh 'php -v'
	  sh 'composer update'
    }

	stage('Run phplint') {
	  sh 'vendor/bin/phplint'
	}

	stage('Run phpmd') {
	  sh 'vendor/bin/phpmd . --exclude lib,vendor text ruleset.xml'
	}

	stage('Run phpunit') {
	  sh 'vendor/bin/phpunit tests'
	}

	stage('Run phpcpd') {
	  sh 'vendor/bin/phpcpd . --exclude lib --exclude vendor'
	}

	// Very strict... 
		//  sh 'vendor/bin/phpcs . --ignore=vendor'
	
	//Build and deploy (not when called from Gerrit): 
		// vendor/bin/phpdox (requires config file)
		// Push to satis ???
  }
}

// Helper functions
def withPhp(version, cl) {
    withEnv(["PATH=${env.PATH}"]) {
    	sh "#!/bin/bash\nset +x; source ~/.phpbrew/bashrc; phpbrew use $version"
    }
    withEnv([
       	"PHPBREW_ROOT=/home/jenkins-slave/.phpbrew",
    	"PHPBREW_HOME=/home/jenkins-slave/.phpbrew",
    	"PHPBREW_BIN=/home/jenkins-slave/.phpbrew/bin",
    	"PHPBREW_LOOKUP_PREFIX=",
    	"PATH_WITHOUT_PHPBREW=${env.PATH}",    	
		"PHPBREW_PHP=php-$version",    
    	"PHPBREW_PATH=/home/jenkins-slave/.phpbrew/php/php-${version}/bin",
    	"PATH=/home/jenkins-slave/.phpbrew/php/php-${version}/bin:${env.PATH}"
    ]) {
        cl()
    }
}
