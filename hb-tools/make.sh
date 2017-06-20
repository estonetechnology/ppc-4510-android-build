#!/bin/bash
BUILD_TIME=`date +%Y%m%d`
ROOT_PWD=`pwd`
MODULE_NAME="4510-VKI-MNC-HABEY"

#sabresd_6dq-user
ANDROID_PRODUCT=sabresd_6dq
BUILD_MODE=user #eng or user
IMG_OUT_DIR=`pwd`/out/target/product/$ANDROID_PRODUCT
MFG_FILE_PATH="`pwd`/build/hb-tools/mfgtools/Profiles/Linux/OS Firmware/files/android/sabresd/";

MFG_UBOOT_OUT="`pwd`/build/hb-tools/mfgtools/Profiles/Linux/OS Firmware/firmware/";

OTA_ZIP="`pwd`/out/target/product/$ANDROID_PRODUCT/$ANDROID_PRODUCT-ota-eng.$USER.zip"
OTA_OUT="`pwd`/build/hb-tools/$MODULE_NAME-update-$BUILD_TIME.ota.zip"

#ERROR ID
E_BUILD_UBOO=-1
E_BUILD_KERNEL=-2
E_BUILD_BOOTIMAGE=-3
E_BUILD_ANDROID=-4

source /opt/jdk/jdk17.sh
export HOST_PROCESSOR=`cat /proc/cpuinfo | grep processor | wc -l`
BUILD_THREAD=$(expr $HOST_PROCESSOR \* 2)

function build_uboot () {
        #build uboot use android, not support clean
        rm $IMG_OUT_DIR/u-boot*
        source build/envsetup.sh
        lunch $ANDROID_PRODUCT-$BUILD_MODE
        make bootloader || { return $E_BUILD_UBOOT;}
        return 0
}

function build_kernel () {
        #build kernel use android, not support clean
        source build/envsetup.sh
        lunch $ANDROID_PRODUCT-$BUILD_MODE
        make kernelimage || { return $E_BUILD_KERNEL;}
        return 0
}

function build_bootimage () {
        #build kernel use android, not support clean
        source build/envsetup.sh
        lunch $ANDROID_PRODUCT-$BUILD_MODE
        make bootimage || { return $E_BUILD_BOOTIMAGE;}
        return 0
}

function build_android () {
        rm $IMG_OUT_DIR/*.img
        rm $IMG_OUT_DIR/*.imx
	rm $IMG_OUT_DIR/*.dtb
        rm $IMG_OUT_DIR/system/build.prop

        if [[ $1 == "clean" || $1 == "distclean" ]]; then
                source build/envsetup.sh
                lunch $ANDROID_PRODUCT-$BUILD_MODE
                make clean || { return $E_CLEAN_ANDROID;}
                return 0
        fi  
	source build/envsetup.sh
	lunch $ANDROID_PRODUCT-$BUILD_MODE
        make -j$BUILD_THREAD
	make|| { return $E_BUILD_ANDROID;}
        return 0
}

function build_MFG () {
	cd build/hb-tools
        rm mfgtools/ -rf
        git checkout .
        cd -
	cp -u $IMG_OUT_DIR/u-boot-imx*.imx "$MFG_FILE_PATH"
	cp -u $IMG_OUT_DIR/*.img "$MFG_FILE_PATH"
	cp -u $IMG_OUT_DIR/u-boot-mfg*.imx "$MFG_UBOOT_OUT"
	cp -u $IMG_OUT_DIR/imx6*.dtb "$MFG_UBOOT_OUT"
	cd build/hb-tools
	MFG_OUT_ZIP="`pwd`/$MODULE_NAME-$BUILD_TIME.zip"
	zip -ru $MODULE_NAME.zip mfgtools
	mv $MODULE_NAME.zip "$MFG_OUT_ZIP"
	echo -e "\033[31m out: $MFG_OUT_ZIP \033[0m"
	cd -
	return 0
}

function build_recovery () {
        source build/envsetup.sh
        lunch $ANDROID_PRODUCT-$BUILD_MODE
        make otapackage -j$BUILD_THREAD|| { return $E_BUILD_BOOTIMAGE;}
	cp $OTA_ZIP $OTA_OUT
	echo -e "\033[31m out: $OTA_OUT \033[0m"
	return 0
}
 
case "$1" in

u )
build_uboot $2
;;

k )
build_kernel $2
;;

b )
build_bootimage $2
;;

a )
build_android $2
;;

MFG )
build_MFG $2
;;

OTA )
build_recovery $2
;;

esac




