#!/bin/bash

set -e

function mx_kk_20130801_sdk()
{
	echo -e "\ndownload begin\n"
	repo init -u 10.10.61.20:/home/svn/amlogic_jb_mr1_mirror/jellybean/platform/manifest.git -b sdmc_nbox --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	repo sync -j4
	repo forall -c git checkout -b sdmc_nbox_130801 svn_org/sdmc_nbox_130801
	cd external
	git clone 10.10.61.20:/home/svn/amlogic_jb_mr1_mirror/jellybean/platform/external/sdmc-libs.git
	cd sdmc-libs
	git checkout -b sdmc_nbox_130801 origin/sdmc_nbox_130801
	cd ../../
	echo -e "\ndownload finished\n"
}

function mx_kk_20140428_sdk()
{
	echo -e "\ndownload begin\n"
	repo init -u 10.10.61.20:/home/svn/amlogic_jb_mr1_mirror/jellybean/platform/manifest.git -b sdmc_nbox_140428 --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	repo sync -j4
	repo forall -c git checkout -b sdmc_nbox_140428	svn_org/sdmc_nbox_140428
	cd external
	git clone 10.10.61.20:/home/svn/amlogic_jb_mr1_mirror/jellybean/platform/external/sdmc-libs.git
	cd sdmc-libs
	git checkout -b sdmc_nbox_140428 origin/sdmc_nbox_140428
	cd ../../
	echo -e "\ndownload finished\n"
}

function m8_kk_20150313_sdk()
{
	echo -e "\ndownload begin\n"
	repo init -u 10.10.61.20:/home/svn/amlogic_kk_git_mirror/kitkat/platform/manifest.git -b sdmc_m8_20150313 --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	repo sync -j4
	repo forall -c git checkout -b sdmc_m8_20150313_patch svn_org/sdmc_m8_20150313_patch
	mkdir -p vendor/sdmc
	cd vendor/sdmc
	git clone 10.10.61.20:/home/svn/amlogic_jb_mr1_mirror/jellybean/platform/external/sdmc-libs.git
	cd sdmc-libs
	git checkout -b sdmc_s805_20141114_patch origin/sdmc_s805_20141114_patch
	cd ../../../
	echo -e "\ndownload finished\n"
}

function m8_kk_20150414_sdk()
{
	echo -e "\ndownload begin\n"
	repo init -u 10.10.61.20:/home/svn/amlogic_kk_git_mirror/kitkat/platform/manifest.git -b sdmc_m8_20150414_patch --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	repo sync -j4
	repo forall -c git checkout -b sdmc_m8_20150414_patch svn_org/sdmc_m8_20150414_patch
	echo -e "\ndownload finished\n"
}

function m8_kk_20150612_sdk()
{
	echo -e "\ndownload begin\n"
	repo init -u 10.10.61.20:/home/svn/amlogic_kk_git_mirror/kitkat/platform/manifest.git -b sdmc_m8_20150612 --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	repo sync -j4
	repo forall -c git checkout -b sdmc_m8_20150612 svn_org/sdmc_m8_20150612
	echo -e "\ndownload finished\n"
}

function m8_l_20150514_sdk()
{
	echo -e "\ndownload begin\n"
	repo init -u 10.10.61.20:/home/svn/amlogic_kk_git_mirror/kitkat/platform/manifest.git -b sdmc_m8_5.0_20150514 --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	repo sync -j4
	repo forall -c git checkout -b sdmc_m8_lollipop_20150514 svn_org/sdmc_m8_lollipop_20150514
	echo -e "\ndownload finished\n"
}

function s805_buildrootSLC256_sdk()
{
	echo -e "\ndownload begin\n"
	git clone svn@10.10.61.22:/home/svn/amlogic_s805_linux_git_mirror/  -b	kk-amlogic_SLC256
	echo -e "\ndownload finished\n"
}

function s905_l_20150108_sdk()
{
	echo -e "\ndownload begin\n"
	repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_l_gx_git_mirror/l-amlogic-gx/platform/manifest.git -b l-amlogic-gx --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	cd .repo/manifests
	cp openlinux_l-amlogic_20151031_patch_0108.xml default.xml
	sed -i "s/ssh:\/\/git@openlinux.amlogic.com/ssh:\/\/amlogic_l_group@10.10.61.22\/home\/svn\/amlogic_l_gx_git_mirror/" default.xml
	cd ../../
	repo sync -j4
	cd vendor/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/playready.git -b l-amlogic
	cd amlogic/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/tdk.git -b tdk-v1.2
	cd ../../
	echo -e "\ndownload finished\n"
}

function s905_l_20150401_sdk()
{
	echo -e "\ndownload begin\n"
	repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_l_gx_git_mirror/l-amlogic-gx/platform/manifest.git -b l-amlogic-gx --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	cd .repo/manifests
	cp openlinux_l-amlogic_20151031_patch_0401.xml default.xml
	sed -i "s/ssh:\/\/git@openlinux.amlogic.com/ssh:\/\/amlogic_l_group@10.10.61.22\/home\/svn\/amlogic_l_gx_git_mirror/" default.xml
	cd ../../
	repo sync -j4
	cd vendor/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/playready.git -b l-amlogic
	cd amlogic/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/tdk.git -b tdk-v1.2
	cd ../../
	echo -e "\ndownload finished\n"
}

function s912_m_20160907_sdk()
{
	echo -e "\ndownload begin\n"
	repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/platform/manifest.git -b m-amlogic-openlinux-20160907 --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	cd .repo/manifests
	cp openlinux_m-amlogic_20160907.xml default.xml
	sed -i "s/remote fetch=\"..\/../remote fetch=\"ssh:\/\/amlogic_l_group@10.10.61.22\/home\/svn\/amlogic_m_gxl_git_mirror/" default.xml
	cd ../../
	repo sync -j4
	cd vendor/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/playready.git -b m-amlogic-3.x
	cd amlogic/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/tdk.git -b tdk-v1.5
	cd ../../
	echo -e "\ndownload finished\n"
}

function s905x_m_20160907_sdk()
{
	s912_m_20160907_sdk
}

function s905d_m_20160907_sdk()
{
	s912_m_20160907_sdk
}

function s905x_m_20160907_vmx_sdk()
{
	echo -e "\ndownload begin\n"
	repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/platform/manifest.git -b m-amlogic-openlinux-20160907 --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	cd .repo/manifests
	cp openlinux_m-amlogic_vmx.xml default.xml
	sed -i "s/remote fetch=\"..\/../remote fetch=\"ssh:\/\/amlogic_l_group@10.10.61.22\/home\/svn\/amlogic_m_gxl_git_mirror/" default.xml
	cd ../../
	repo sync -j4
	cd vendor/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/playready.git -b m-amlogic-3.x
	cd amlogic/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/tdk.git -b tdk-v1.5
	cd ../../
	echo -e "\ndownload finished\n"
}

function his3796MV100_kk_v63_sdk()
{
	echo -e "\ndownload begin\n"
	repo init -u hisilicon_group@10.10.61.22:/home/svn/hisilicon_kk_git_mirror/manifest.git -b his_3796_v58 --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	repo sync -j4
	repo forall -c git checkout -b his_v63_org 	org/his_v63_org
	echo -e "\ndownload finished\n"
}

function his3796MV100_kk_v64_sdk()
{
	echo -e "\ndownload begin\n"
	repo init -u hisilicon_group@10.10.61.22:/home/svn/hisilicon_kk_git_mirror/manifest.git -b his_3796_v58 --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	repo sync -j4
	repo forall -c git checkout -b his_v64_org 	org/his_v64_org
	echo -e "\ndownload finished\n"
}

function his3796MV100_kk_v65_sdk()
{
	echo -e "\ndownload begin\n"
	repo init -u hisilicon_group@10.10.61.22:/home/svn/hisilicon_kk_git_mirror/manifest.git -b his_3796_v58 --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	repo sync -j4
	repo forall -c git checkout -b his_v65_org 	org/his_v65_org
	echo -e "\ndownload finished\n"
}

function his3796MV100_l_v20_sdk()
{
	echo -e "\ndownload begin\n"
	repo init -u hisilicon_group@10.10.61.22:/home/svn/hisilicon_l_kk_git_mirror/manifest.git -b his_l_v20 --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	repo sync -j4
	repo forall -c git checkout -b his_l_v20_org org/his_l_v20_org
	echo -e "\ndownload finished\n"
}

function s912_n_20161230_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_n_gx_git_mirror/n-amlogic/platform/manifest.git -b n-amlogic --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	cd .repo/manifests
	cp n-amlogic_openlinux-20161230.xml default.xml
	sed -i "s/remote fetch=\"..\/../remote fetch=\"ssh:\/\/amlogic_l_group@10.10.61.22\/home\/svn\/amlogic_n_gx_git_mirror/" default.xml
	cd ../../
	repo sync -j4
	cd vendor/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/playready.git -b n-amlogic-3.x
	cd amlogic/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/tdk.git -b tdk-v2.0
	cd ../../
	echo -e "\ndownload finished\n"
}

function s905x_n_20161230_sdk()
{
    s912_n_20161230_sdk
}

function s905d_n_20161230_sdk()
{
    s912_n_20161230_sdk
}

function s912_n_20170222_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_n_gx_git_mirror/n-amlogic/platform/manifest.git -b n-amlogic --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	cd .repo/manifests
	cp n-amlogic_openlinux-20170222-ott.xml default.xml
	sed -i "s/remote fetch=\"..\/../remote fetch=\"ssh:\/\/amlogic_l_group@10.10.61.22\/home\/svn\/amlogic_n_gx_git_mirror/" default.xml
	cd ../../
	repo sync -j4
	cd vendor/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/playready.git -b n-amlogic-3.x
	cd amlogic/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/tdk.git -b tdk-v2.0
	cd ../../
	echo -e "\ndownload finished\n"
}

function s905x_n_20170222_sdk()
{
    s912_n_20170222_sdk
}

function s905d_n_20170222_sdk()
{
    s912_n_20170222_sdk
}

function s912_n_20170321_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_n_gx_git_mirror/n-amlogic/platform/manifest.git -b n-amlogic --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	cd .repo/manifests
	cp n-amlogic_openlinux-20170321.xml default.xml
	sed -i "s/remote fetch=\"..\/../remote fetch=\"ssh:\/\/amlogic_l_group@10.10.61.22\/home\/svn\/amlogic_n_gx_git_mirror/" default.xml
	cd ../../
	repo sync -j4
	cd vendor/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/playready.git -b n-amlogic-3.x
	cd amlogic/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/tdk.git -b tdk-v2.0
	cd ../../
	echo -e "\ndownload finished\n"
}

function s905x_n_20170321_sdk()
{
    s912_n_20170321_sdk
}

function s905d_n_20170222_sdk()
{
    s912_n_20170321_sdk
}

function s912_n_20170425_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_n_gx_git_mirror/n-amlogic/platform/manifest.git -b n-amlogic --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	cd .repo/manifests
	cp n-amlogic_openlinux-20170425.xml default.xml
	sed -i "s/remote fetch=\"..\/../remote fetch=\"ssh:\/\/amlogic_l_group@10.10.61.22\/home\/svn\/amlogic_n_gx_git_mirror/" default.xml
	cd ../../
	repo sync -j4
	cd vendor/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/playready.git -b n-amlogic-3.x
	cd amlogic/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/tdk.git -b tdk-v2.0.2
	cd ../../
	echo -e "\ndownload finished\n"
}

function s905x_n_20170425_sdk()
{
    s912_n_20170425_sdk
}

function s905d_n_20170425_sdk()
{
    s912_n_20170425_sdk
}

function his3798MV200_n_v23_sdk()
{
	echo -e "\ndownload begin\n"
	repo init -u hisilicon_group@10.10.61.22:/home/svn/hisilicon_n_git_mirror/manifest.git -b master --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	repo sync -j4
	repo forall -c git checkout -b his_n_v23_org org/his_n_v23_org
	echo -e "\ndownload finished\n"
}

function s912_n_20170619_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_n_gx_git_mirror/n-amlogic/platform/manifest.git -b n-amlogic --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	cd .repo/manifests
	cp n-amlogic_openlinux-20170619.xml default.xml
	sed -i "s/remote fetch=\"..\/../remote fetch=\"ssh:\/\/amlogic_l_group@10.10.61.22\/home\/svn\/amlogic_n_gx_git_mirror/" default.xml
	cd ../../
	repo sync -j4
	cd vendor/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/playready.git -b n-amlogic-3.x
	cd amlogic/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/tdk.git -b tdk-v2.0.2
	cd ../../
	echo -e "\ndownload finished\n"
}

function s905x_n_20170619_sdk()
{
    s912_n_20170619_sdk
}

function s905d_n_20170619_sdk()
{
    s912_n_20170619_sdk
}

function s912_n_20170804_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_n_gx_git_mirror/n-amlogic/platform/manifest.git -b n-amlogic --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	cd .repo/manifests
	cp n-amlogic_openlinux-20170619-patch20170804.xml default.xml
	sed -i "s/remote fetch=\"..\/../remote fetch=\"ssh:\/\/amlogic_l_group@10.10.61.22\/home\/svn\/amlogic_n_gx_git_mirror/" default.xml
	cd ../../
	repo sync -j4
	cd vendor/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/playready.git -b n-amlogic-3.x
	cd amlogic/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/tdk.git -b tdk-v2.0.2
	cd ../../
	echo -e "\ndownload finished\n"
}

function s905x_n_20170804_sdk()
{
    s912_n_20170804_sdk
}

function s905d_n_20170804_sdk()
{
    s912_n_20170804_sdk
}

function s912_n_20170928_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_n_gx_git_mirror/n-amlogic/platform/manifest.git -b n-amlogic --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	cd .repo/manifests
	cp n-amlogic_openlinux-20170619-patch20170928.xml  default.xml
	sed -i "s/remote fetch=\"..\/../remote fetch=\"ssh:\/\/amlogic_l_group@10.10.61.22\/home\/svn\/amlogic_n_gx_git_mirror/" default.xml
	cd ../../
	repo sync -j4
	cd vendor/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/playready.git -b n-amlogic-3.x
	cd amlogic/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/tdk.git -b tdk-v2.0.2
	cd ../../
	echo -e "\ndownload finished\n"
}

function s905x_n_20170928_sdk()
{
    s912_n_20170928_sdk
}

function s905x_n_20170928_vmx_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_n_gx_git_mirror/n-amlogic/platform/manifest.git -b n-amlogic --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	cd .repo/manifests
	cp n-amlogic_openlinux-20170619-patch20170928.xml  default.xml
	sed -i "s/remote fetch=\"..\/../remote fetch=\"ssh:\/\/amlogic_l_group@10.10.61.22\/home\/svn\/amlogic_n_gx_git_mirror/" default.xml
	cd ../../
	repo sync -j4
	cd vendor/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/playready.git -b n-amlogic-3.x
	cd amlogic/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/tdk.git -b projects/verimatrix/tdk-v1.4
	cd ../../
	echo -e "\ndownload finished\n"
}

function s905d_n_20170928_sdk()
{
    s912_n_20170928_sdk
}

function s905x_n_20180213_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_n_gx_git_mirror/n-amlogic/platform/manifest.git -b n-amlogic --repo-url=$USER@10.10.61.20:/usr/tools/repo.git
	cd .repo/manifests
	cp n-amlogic_openlinux-20170619-patch20180213.xml  default.xml
	sed -i "s/remote fetch=\"..\/../remote fetch=\"ssh:\/\/amlogic_l_group@10.10.61.22\/home\/svn\/amlogic_n_gx_git_mirror/" default.xml
	cd ../../
	repo sync -j4
	cd vendor/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/playready.git -b n-amlogic-3.x
	cd amlogic/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/tdk.git -b tdk-v2.0.2
	cd ../../
	echo -e "\ndownload finished\n"
}

function s905x_o_20171123_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_o_gx_git_mirror/o-amlogic/platform/manifest.git -b o-amlogic --repo-url=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_o_gx_git_mirror/repo.git
	repo init -m o-amlogic_openlinux-20171123.xml
	repo sync -j4
	cd vendor/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/playready.git  -b o-amlogic-openlinux-20171024
	cd amlogic/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/tdk.git -b o-amlogic-openlinux-20171024
	cd ../../
	echo -e "\ndownload finished\n"
}

function s905d_o_20171123_sdk()
{
    s905x_o_20171123_sdk
}

function s905x_o_20180126_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_o_gx_git_mirror/o-amlogic/platform/manifest.git -b o-amlogic --repo-url=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_o_gx_git_mirror/repo.git
	repo init -m o-amlogic_openlinux-20171215-patch20180126.xml
	repo sync -j4
	cd vendor/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/playready.git  -b o-amlogic-openlinux-20171215
	cd amlogic/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/tdk.git -b tdk-v2.4
	cd ../../
	echo -e "\ndownload finished\n"
}

function s905d_o_20180126_sdk()
{
    s905x_o_20180126_sdk
}

function s805x_o_20180126_sdk()
{
    s905x_o_20180126_sdk
}

function s905x_o_20180412_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_o_gx_git_mirror/o-amlogic/platform/manifest.git -b o-amlogic --repo-url=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_o_gx_git_mirror/repo.git
	repo init -m o-amlogic_openlinux-20171215-patch20180412.xml
	repo sync -j4
	cd vendor/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/playready.git  -b o-amlogic-openlinux-20171215
	cd amlogic/
	git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/tdk.git -b tdk-v2.4
	cd ../../
	echo -e "\ndownload finished\n"
}

function s905d_o_20180412_sdk()
{
    s905x_o_20180412_sdk
}

function s805x_o_20180412_sdk()
{
    s905x_o_20180412_sdk
}

function s905x_o_hailstorm_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_o_gx_git_mirror/o-amlogic/platform/manifest.git -b o-amlogic --repo-url=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_o_gx_git_mirror/repo.git
        repo init -m o-amlogic_openlinux-hailstorm-v1.0.xml
        repo sync -j4
        cd vendor/
        git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/playready.git  -b o-amlogic-openlinux-20171215
        cd amlogic/
        git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/tdk.git -b o-amlogic-openlinux-20171215
        cd ../../
        echo -e "\ndownload finished\n"
}

function p_dev_20181105_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/p-amlogic/platform/manifest.git -b p-amlogic --repo-url=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/repo.git -m p-amlogic_openlinux-20181105.xml
        repo sync -j4
        cd vendor/amlogic/common/prebuilt/libmediadrm/
        git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/playready.git  -b p-amlogic-mainline-20181025
        cd ../../
		mv tdk tdk_bck
        git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/tdk.git -b p-amlogic-mainline-20181025
		cp -rf tdk_bck/linuxdriver tdk/
		rm -rf tdk_bck
        cd ../../../
        echo -e "\ndownload finished\n"
}

function p_dev_20181208_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/p-amlogic/platform/manifest.git -b p-amlogic --repo-url=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/repo.git -m p-amlogic_openlinux-20181208.xml
		repo sync -j4

        echo -e "\ndownload finished\n"
}

function p_dev_20190109_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/p-amlogic/platform/manifest.git -b p-amlogic --repo-url=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/repo.git -m openlinux_ott_sdk_november.xml
		repo sync -j4
        cd vendor/amlogic/common/prebuilt/libmediadrm/
        git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/playready.git -b p-amlogic-mainline_9.2.1811_21
        cd ../../
		mv tdk tdk_bck
        git clone amlogic_l_group@10.10.61.22:/home/svn/amlogic_m_gxl_git_mirror/m-amlogic/tdk.git -b p-amlogic-mainline_9.2.1811_21
		cp -rf tdk_bck/linuxdriver tdk/
		rm -rf tdk_bck
        cd ../../../

        echo -e "\ndownload finished\n"
}

function p_dev_20190111_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/p-amlogic/platform/manifest.git -b p-amlogic --repo-url=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/repo.git -m p-amlogic_openlinux-20190111.xml
		repo sync -j4

        echo -e "\ndownload finished\n"
}

function s905x_p_hailstore_2.0_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/p-amlogic/platform/manifest.git -b p-amlogic --repo-url=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/repo.git -m p-amlogic_openlinux-hailstorm-v2.0.xml
		repo sync -j4

        echo -e "\ndownload finished\n"
}

function p_dev_hailstorm_2.0.1_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/p-amlogic/platform/manifest.git -b p-amlogic --repo-url=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/repo.git -m p-amlogic_openlinux-hailstorm-v2.0.1.xml
		repo sync -j4

        echo -e "\ndownload finished\n"
}

function p_dev_hailstorm_2.0.2_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/p-amlogic/platform/manifest.git -b p-amlogic --repo-url=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/repo.git -m p-amlogic_openlinux-hailstorm-v2.0.2.xml
		repo sync -j8

        echo -e "\ndownload finished\n"
}

function p_dev_hailstorm_2.1_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/p-amlogic/platform/manifest.git -b p-amlogic --repo-url=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/repo.git -m p-amlogic_openlinux-hailstorm-v2.1.xml
		repo sync -j8

        echo -e "\ndownload finished\n"
}

function p_dev_20190415_aosp_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/p-amlogic/platform/manifest.git -b p-amlogic --repo-url=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/repo.git -m p-amlogic_openlinux-20190415_aosp.xml
		repo sync -j4

        echo -e "\ndownload finished\n"
}

function s905x3_p_20190531_ott_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/p-amlogic/platform/manifest.git -b p-amlogic --repo-url=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/repo.git -m p-amlogic-openlinux-20190531-ott.xml
		repo sync -j4

        echo -e "\ndownload finished\n"
}

function p_dev_20190720_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/p-amlogic/platform/manifest.git -b p-amlogic --repo-url=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/repo.git -m p-amlogic-openlinux-20190720-ott.xml
		repo sync -j8

        echo -e "\ndownload finished\n"
}

function p_dev_20191029_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/p-amlogic/platform/manifest.git -b p-amlogic --repo-url=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/repo.git -m p-amlogic-openlinux-20191029-ott.xml
		repo sync -j8

        echo -e "\ndownload finished\n"
}

function p_dev_20191030_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/p-amlogic/platform/manifest.git -b p-amlogic --repo-url=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_p_mirror/repo.git -m p-amlogic-openlinux-20191030-ott.xml
		repo sync -j8

        echo -e "\ndownload finished\n"
}

function q_dev_20191031_sdk()
{
    echo -e "\ndownload begin\n"
    repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/google_q_mirror/platform/vendor/pdk/franklin/franklin-userdebug/manifest.git -b q-tv-ref-amlogic-release --repo-url=ssh://amlogic_l_group@10.10.61.22/home/svn/google_q_mirror/git-repo.git 
	
	repo sync -j8
	
	echo -e "\ndownload sdk from google finished\n"
	
	cd ../
	mkdir tmp
	cd tmp
	repo init -u ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_q_mirror/q-amlogic/platform/manifest.git -b q-amlogic --repo-url=ssh://amlogic_l_group@10.10.61.22/home/svn/amlogic_q_mirror/repo.git -m q-amlogic_openlinux-20191031.xml
	
	repo sync -j8
	
	echo -e "\ndownload sdk from amlogic finished\n"

	cd ../$SDK_DIR
	mkdir -p bootloader/uboot-repo/bl2
	mkdir -p bootloader/uboot-repo/bl30
	mkdir -p bootloader/uboot-repo/bl31
	mkdir -p bootloader/uboot-repo/bl31_1.3
	mkdir -p bootloader/uboot-repo/bl32
	mkdir -p bootloader/uboot-repo/bl33
	mkdir -p bootloader/uboot-repo/fip
	cd bootloader/uboot-repo/bl2
	git clone ../../../../tmp/bootloader/uboot-repo/bl2/bin/
	cd ../bl30/
	git clone ../../../../tmp/bootloader/uboot-repo/bl30/bin/
	cd ../bl31/
	git clone ../../../../tmp/bootloader/uboot-repo/bl31/bin/
	cd ../bl31_1.3/
	git clone ../../../../tmp/bootloader/uboot-repo/bl31_1.3/bin/
	cd ../bl32/
	git clone ../../../../tmp/bootloader/uboot-repo/bl32/bin/
	cd ../bl33/
	git clone ../../../../tmp/bootloader/uboot-repo/bl33/v2015/
	cd ../
	git clone ../../../tmp/bootloader/uboot-repo/fip
	cp ../../../tmp/bootloader/uboot-repo/mk ./
	chmod 777 mk
	cd ../../
	git clone ../tmp/common/
	cd hardware/
	mkdir -p wifi/broadcom/drivers/
	mkdir -p wifi/qualcomm/drivers/
	mkdir -p wifi/realtek/drivers/
	cd wifi/broadcom/drivers/
	git clone ../../../../../tmp/hardware/wifi/broadcom/drivers/ap6xxx/
	cd ../../qualcomm/drivers
	git clone ../../../../../tmp/hardware/wifi/qualcomm/drivers/qca6174/
	cd ../../realtek/drivers/
	git clone ../../../../../tmp/hardware/wifi/realtek/drivers/8822cs/
	cd ../../../amlogic/
	git clone ../../../tmp/hardware/amlogic/media_modules/
	cd ../../
	cd vendor/amlogic/common/tdk/
	git clone ../../../../../tmp/vendor/amlogic/common/tdk/linuxdriver/
	cd ../
	git clone ../../../../tmp/vendor/amlogic/common/gpu
	cd ../../../../
	rm -rf tmp
	
    echo -e "\ndownload finished\n"
}

function mkdir_sdk()
{
	sdk_dir=$1

    while [ -d "$sdk_dir" ]
	do
	    echo  "$sdk_dir has existed, you can enter a custom directory ["eg:normal"]"
        export TARGET_SDK_DIR_TYPE=
		export ANSWER=
        local ANSWER
        while [ -z $TARGET_SDK_DIR_TYPE ]
        do
            read ANSWER
            if [ -n "$ANSWER" ] ; then
			    sdk_dir=$1_$ANSWER
                break
            fi
        done
    done

	mkdir $sdk_dir
    echo "sdk will download in $sdk_dir directory"
    cd $sdk_dir
}

function choose_info()
{
	echo
	echo "You're downloding a soc sdk"
	echo
	echo "Lunch menu... pick a combo:"
	echo "          1. mx 20130801 android 4.2 sdk"
	echo "          2. mx 20140428 android 4.2 sdk"
	echo "          3. m8 20150313 android 4.4 sdk"
	echo "          4. m8 20150414 android 4.4 sdk"
	echo "          5. m8 20150612 android 4.4 sdk"
	echo "          6. m8 20150514 android 5.1 sdk"
	echo "          7. s805 SLC256 buildroot sdk"
	echo "          8. s905 20150108 android 5.1 sdk"
	echo "          9. s905 20150401 android 5.1 sdk"
	echo "          10. s912 20160907 android 6.0 sdk"
	echo "          11. s905x 20160907 android 6.0 sdk"
	echo "          12. s905d 20160907 android 6.0 sdk"
	echo "          13. his3796MV100 v63 android 4.4 sdk"
	echo "          14. his3796MV100 v64 android 4.4 sdk"
	echo "          15. his3796MV100 v65 android 4.4 sdk"
	echo "          16. his3796MV100 v20 android 5.1 sdk"
	echo "          17. s905x 20160907 android 6.0 verimatrix sdk"
	echo "          18. s912 20161230 android 7.0 sdk"
	echo "          19. s905x 20161230 android 7.0 sdk"
	echo "          20. s905d 20161230 android 7.0 sdk"
	echo "          21. s912 20170222 android 7.1 sdk"
	echo "          22. s905x 20170222 android 7.1 sdk"
	echo "          23. s905d 20170222 android 7.1 sdk"
	echo "          24. s912 20170321 android 7.1 sdk"
	echo "          25. s905x 20170321 android 7.1 sdk"
	echo "          26. s905d 20170321 android 7.1 sdk"
	echo "          27. s912 20170425 android 7.1 sdk"
	echo "          28. s905x 20170425 android 7.1 sdk"
	echo "          29. s905d 20170425 android 7.1 sdk"
	echo "          30. his3798MV200 v23 android 7.0 sdk"
	echo "          31. s912 20170619 android 7.1 sdk"
	echo "          32. s905x 20170619 android 7.1 sdk"
	echo "          33. s905d 20170619 android 7.1 sdk"
	echo "          34. s912 20170804 android 7.1 sdk"
	echo "          35. s905x 20170804 android 7.1 sdk"
	echo "          36. s905d 20170804 android 7.1 sdk"
	echo "          37. s912 20170928 android 7.1 sdk"
	echo "          38. s905x 20170928 android 7.1 sdk"
	echo "          39. s905x 20170928 android 7.1 vmx sdk"
	echo "          40. s905d 20170928 android 7.1 sdk"
	echo "          41. s905x 20180213 android 7.1 sdk"
	echo "          42. s905x 20171123 android 8.0 sdk"
	echo "          43. s905d 20171123 android 8.0 sdk"	
	echo "          44. s905x 20180126 android 8.0 sdk"	
	echo "          45. s905d 20180126 android 8.0 sdk"	
	echo "          46. s805x 20180126 android 8.0 sdk"	
	echo "          47. s905x 20180412 android 8.0 sdk"	
	echo "          48. s905d 20180412 android 8.0 sdk"	
	echo "          49. s805x 20180412 android 8.0 sdk"		
	echo "          50. s905x hailstorm android 8.0 sdk"
	echo "          51. s905x s905d s805x s905x2 s905y2 20181105 android 9 sdk"
	echo "          52. s905x s905d s805x s905x2 s905y2 20181208 android 9 sdk"
	echo "          53. s905x s905d s805x s905x2 s905y2 20190109 android 9 sdk"
	echo "          54. s905x s905d s805x s905x2 s905y2 20190111 android 9 sdk"
	echo "          55. s905x hailstorm 2.0 android 9 sdk"
	echo "          56. s805x s905x s905x2 hailstorm 2.0.1 android 9 sdk"
	echo "          57. s805x s905x hailstorm 2.0.2 android 9 sdk"
	echo "          58. s905x2  s905y2 hailstorm 2.1 android 9 sdk"
	echo "          59. s805x s905x s905x2 20190415 aosp android 9 sdk"
	echo "          60. s905x3 20190531 android 9 ott sdk"
	echo "          61. s905x2  s905x3 20190720 android 9 sdk"
	echo "          62. s905x2  s905x3 20191029 android 9 sdk"
	echo "          63. s912 20191030 android 9 sdk"
	echo "          64. s905x s905x2 s905x3 20191031 android q sdk"
	echo
}

function choose_type()
{
	choose_info
    export TARGET_BUILD_TYPE=
    local ANSWER
    while [ -z $TARGET_BUILD_TYPE ]
    do
        echo -n "Which SDK would you like to download? ["$DEFAULT_NUM"] "
        if [ -z "$1" ] ; then
            read ANSWER
        else
            echo $1
            ANSWER=$1
        fi
        case $ANSWER in
        "")
            echo "please select a sdk to download!"
            ;;
        1)
            echo "downloding mx 20130801 android 4.2 sdk"
			SDK_DIR=mx_kk_20130801_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
            ;;
        2)
            echo "downloding mx 20140428 android 4.2 sdk"
			SDK_DIR=mx_kk_20140428_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
            ;;
        3)
            echo "downloding m8 20150313 android 4.4 sdk"
			SDK_DIR=m8_kk_20150313_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
            ;;
        4)
            echo "downloding m8 20150414 android 4.4 sdk"
			SDK_DIR=m8_kk_20150414_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
            ;;
        5)
            echo "downloding m8 20150612 android 4.4 sdk"
			SDK_DIR=m8_kk_20150612_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
            ;;
        6)
            echo "downloding m8 20150514 android 5.1 sdk"
			SDK_DIR=m8_l_20150514_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
            ;;
        7)
            echo "downloding s805 SLC256 buildroot sdk"
			SDK_DIR=s805_buildrootSLC256_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
            ;;
        8)
            echo "downloding s905 20150108 android 5.1 sdk"
			SDK_DIR=s905_l_20150108_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
            ;;
        9)
            echo "downloding s905 20150401 android 5.1 sdk"
			SDK_DIR=s905_l_20150401_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
            ;;
        10)
            echo "downloding s912 20160907 android 6.0 sdk"
			SDK_DIR=s912_m_20160907_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        11)
            echo "downloding s905x 20160907 android 6.0 sdk"
			SDK_DIR=s905x_m_20160907_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        12)
            echo "downloding s905d 20160907 android 6.0 sdk"
			SDK_DIR=s905d_m_20160907_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        13)
            echo "downloding his3796MV100 v63 android 4.4 sdk"
			SDK_DIR=his3796MV100_kk_v63_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        14)
            echo "downloding his3796MV100 v64 android 4.4 sdk"
			SDK_DIR=his3796MV100_kk_v64_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        15)
            echo "downloding his3796MV100 v65 android 4.4 sdk"
			SDK_DIR=his3796MV100_kk_v65_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        16)
            echo "downloding his3796MV100 v20 android 5.1 sdk"
			SDK_DIR=his3796MV100_l_v20_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        17)
            echo "downloding s905x 20160907 android 6.0 verimatrix sdk"
			SDK_DIR=s905x_m_20160907_vmx_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        18)
            echo "downloding s912 20161230 android 7.0 sdk"
			SDK_DIR=s912_n_20161230_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        19)
            echo "downloding s905x 20161230 android 7.0 sdk"
			SDK_DIR=s905x_n_20161230_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        20)
            echo "downloding s905d 20161230 android 7.0 sdk"
			SDK_DIR=s905d_n_20161230_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        21)
            echo "downloding s912 20170222 android 7.1 sdk"
			SDK_DIR=s912_n_20170222_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        22)
            echo "downloding s905x 20170222 android 7.1 sdk"
			SDK_DIR=s905x_n_20170222_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        23)
            echo "downloding s905d 20170222 android 7.1 sdk"
			SDK_DIR=s905d_n_20170222_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        24)
            echo "downloding s912 20170321 android 7.1 sdk"
			SDK_DIR=s912_n_20170321_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        25)
            echo "downloding s905x 20170321 android 7.1 sdk"
			SDK_DIR=s905x_n_20170321_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        26)
            echo "downloding s905d 20170321 android 7.1 sdk"
			SDK_DIR=s905d_n_20170321_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        27)
            echo "downloding s912 20170425 android 7.1 sdk"
			SDK_DIR=s912_n_20170425_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        28)
            echo "downloding s905x 20170425 android 7.1 sdk"
			SDK_DIR=s905x_n_20170425_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        29)
            echo "downloding s905d 20170425 android 7.1 sdk"
			SDK_DIR=s905d_n_20170425_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        30)
            echo "downloding his3798MV200 v23 android 7.0 sdk"
			SDK_DIR=his3798MV200_n_v23_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        31)
            echo "downloding s912 20170619 android 7.1 sdk"
			SDK_DIR=s912_n_20170619_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        32)
            echo "downloding s905x 20170619 android 7.1 sdk"
			SDK_DIR=s905x_n_20170619_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        33)
            echo "downloding s905d 20170619 android 7.1 sdk"
			SDK_DIR=s905d_n_20170619_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        34)
            echo "downloding s912 20170804 android 7.1 sdk"
			SDK_DIR=s912_n_20170804_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        35)
            echo "downloding s905x 20170804 android 7.1 sdk"
			SDK_DIR=s905x_n_20170804_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        36)
            echo "downloding s905d 20170804 android 7.1 sdk"
			SDK_DIR=s905d_n_20170804_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        37)
            echo "downloding s912 20170928 android 7.1 sdk"
			SDK_DIR=s912_n_20170928_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        38)
            echo "downloding s905x 20170928 android 7.1 sdk"
			SDK_DIR=s905x_n_20170928_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        39)
            echo "downloding s905x 20170928 android 7.1 vmx sdk"
			SDK_DIR=s905x_n_20170928_vmx_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        40)
            echo "downloding s905d 20170928 android 7.1 sdk"
			SDK_DIR=s905d_n_20170928_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        41)
            echo "downloding s905x 20180213 android 7.1 sdk"
			SDK_DIR=s905x_n_20180213_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;	
        42)
            echo "downloding s905x 20171123 android 8.0 sdk"
			SDK_DIR=s905x_o_20171123_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;	
        43)
            echo "downloding s905d 20171123 android 8.0 sdk"
			SDK_DIR=s905d_o_20171123_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;	
        44)
            echo "downloding s905x 20180126 android 8.0 sdk"
			SDK_DIR=s905x_o_20180126_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        45)
            echo "downloding s905d 20180126 android 8.0 sdk"
			SDK_DIR=s905d_o_20180126_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        46)
            echo "downloding s805x 20180126 android 8.0 sdk"
			SDK_DIR=s805x_o_20180126_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;	
        47)
            echo "downloding s905x 20180412 android 8.0 sdk"
			SDK_DIR=s905x_o_20180412_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        48)
            echo "downloding s905d 20180412 android 8.0 sdk"
			SDK_DIR=s905d_o_20180412_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        49)
            echo "downloding s805x 20180412 android 8.0 sdk"
			SDK_DIR=s805x_o_20180412_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;				
        50)
            echo "downloding s905x hailstorm android 8.0 sdk"
			SDK_DIR=s905x_o_hailstorm_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;	
        51)
            echo "downloding s905x s905d s805x s905x2 s905y2 20181105 android 9 sdk"
			SDK_DIR=p_dev_20181105_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;	
        52)
            echo "downloding s905x s905d s805x s905x2 s905y2 20181208 android 9 sdk"
			SDK_DIR=p_dev_20181208_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;	
        53)
            echo "downloding s905x s905d s805x s905x2 s905y2 20190109 android 9 sdk"
			SDK_DIR=p_dev_20190109_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        54)
            echo "downloding s905x s905d s805x s905x2 s905y2 20190111 android 9 sdk"
			SDK_DIR=p_dev_20190111_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        55)
            echo "downloding s905x hailstorm 2.0 android 9 sdk"
			SDK_DIR=s905x_p_hailstore_2.0_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        56)
            echo "downloding s805x s905x s905x2 hailstorm 2.0.1 android 9 sdk"
			SDK_DIR=p_dev_hailstorm_2.0.1_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        57)
            echo "downloding s805x s905x hailstorm 2.0.2 android 9 sdk"
			SDK_DIR=p_dev_hailstorm_2.0.2_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        58)
            echo "downloding s905x2 s905y2 hailstorm 2.1 android 9 sdk"
			SDK_DIR=p_dev_hailstorm_2.1_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        59)
            echo "downloding s805x s905x s905x2 20190415 aosp android 9 sdk"
			SDK_DIR=p_dev_20190415_aosp_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        60)
            echo "downloding s905x3 20190531 android 9 ott sdk"
			SDK_DIR=s905x3_p_20190531_ott_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        61)
            echo "downloding s905x2 s905x3 20190720 android 9 sdk"
			SDK_DIR=p_dev_20190720_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        62)
            echo "downloding s905x2 s905x3 20191029 android 9 sdk"
			SDK_DIR=p_dev_20191029_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        63)
            echo "downloding s912 20191030 android 9 sdk"
			SDK_DIR=p_dev_20191030_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        64)
            echo "downloding s905x s905x2 s905x3 20191031 android q sdk"
			SDK_DIR=q_dev_20191031_sdk
			mkdir_sdk $SDK_DIR
			$SDK_DIR
			;;
        *)
            echo
            echo "I didn't understand your response.  Please try again."
            echo
            ;;
        esac
        if [ -n "$SDK_DIR" ] ; then
            break
        fi
    done
}

    choose_type
