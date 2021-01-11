#!/bin/bash

UserName=""
Password=""
userpas=""
f_pass () {
    
    ENTRY=`zenity --password --username --title=Selamat_Datang --timeout=20 `
    
    case $? in
        0)
            UserName=`echo $ENTRY | cut -d'|' -f1`
            Password=`echo $ENTRY | cut -d'|' -f2`
            userpas=$UserName!$Password
				if grep "$userpas" password.txt; 
				then 
						posisi=` grep "$userpas" password.txt`
						echo $posisi
						position=`echo "$posisi" | cut -d'!' -f3`
						echo $position
							
					zenity --info --title="SELAMAT DATANG Di PUSKESMAS MILIK KITA" --text="ANDA MENGAKSES PROGRAM IN DENGAN NAMA: $UserName, JABATAN: $position" --width 500;
					user=$UserName
					if [ $position = "dokter" ]
					then 
						f_tampilan_dokter
					elif [ $position = "resepsionist" ]
					then
						f_tampilan_resepsionist
					else
						f_tampilan_admin
					fi
				else 
				 zenity --warning --title="oops" --text="nama atau password yag anda maskan salah" --width 500 ;
				 f_pass
				fi
				
        ;;
        1)
            zenity --warning --title="oops" --text="login menutup otomatis jika tidak digunakan" --width 500 ;;
        -1)
            echo "An unexpected error has occurred.";;
    esac
}

f_tampilan_resepsionist () {
	pilih="$(zenity --title PUSKESMAS_MILIK_KITA --height=300 --width 500 --list --radiolist --text 'pilih menu yang di inginkan:' --column 'pilih' --column 'menu' FALSE 'REGISTRASI_PASIEN_BARU' FALSE 'REGISTRASI_PASIEN_LAMA' FALSE 'RESET_ANTRIAN' FALSE 'EDIT_AKUN' FALSE 'HAPUS_AKUN' FALSE 'KELUAR')";	
	case "$pilih" in
        REGISTRASI_PASIEN_BARU)
            f_tambah_pasien
            ;;
         
        REGISTRASI_PASIEN_LAMA)
            f_cek_data_pasien
            ;;
		RESET_ANTRIAN)
		f_reset_antrian
            ;;
        EDIT_AKUN)
		f_edit_akun
            ;;
        HAPUS_AKUN)
			f_hapus_akun
			;;
        KELUAR)
			exit
			;;
         
        *)
            zenity --warning --title="oops" --text="PROGRAM DI TUTUP" --width 500 ;
            exit
 
	esac
}
f_cek_data_pasien () {
	ktp=`zenity --forms --title="DATA PASIEN" --text="" --add-entry="NOMOR KTP PASIEN"`
	check=`echo "$ktp" | grep -E ^\-?[0-9]*\.?[0-9]+$`
	if [ "$check" != '' ]
    then
        jumlah=""${#ktp}""
        echo $jumlah
		if [ "$jumlah" = 12 ]
		then
			fi=$(find /root/Documents/project_bash/datapasien -name $ktp.txt)
			if [ "$fi" = "/root/Documents/project_bash/datapasien/$ktp.txt" ]
				then 
				f_sakit
				
			else
			zenity --warning --title="oops" --text="BELUM PASIAN DENGAN NOMOR KTP $tampil, ANDA AKAN MELAKUKAN REGITRSASI PASIEN BARU" --width 500 ;
			f_tambah_pasien
			fi
		else
			
			zenity --warning --title="oops" --text="harap masukan 12 digit no ktp" --width 500 ;
			f_cek_data_pasien
			
		fi
     else
		zenity --warning --title="oops" --text="no ktp harus menggunakan format angka" --width 500 ;
        f_cek_data_pasien
	fi
	
}
ktp=0
tanggal=$(date "+%D %T")
f_tambah_pasien () {
	entry=`zenity --forms --title="DATA PASIEN BARU " \
   --add-entry="NO KTP" \
   --add-entry="NAMA" \
   --add-entry="UMUR" \
   --add-entry="ALAMAT" \
   --add-entry="NOMOR HP"\
   --add-entry="JENIS KELAMIN"`
   ktp=`echo $entry | cut -d'|' -f1`
   nama=`echo $entry | cut -d'|' -f2`
   umur=`echo $entry | cut -d'|' -f3`
   alamat=`echo $entry | cut -d'|' -f4`
   nomor=`echo $entry | cut -d'|' -f5`
   jeniskelamin=`echo $entry | cut -d'|' -f6`
   check=`echo "$ktp" | grep -E ^\-?[0-9]*\.?[0-9]+$`
    if [ $check != '' ]
    then
		jumlah=""${#ktp}""
		if [ $jumlah = 12 ]
		then
			nama1=`echo "$nama" | grep -E ^\-?[0-9]*\.?[0-9]+$`
			if ! [ $nama1 != '' ]
			then
				umur1=`echo "$umur" | grep -E ^\-?[0-9]*\.?[0-9]+$`
				if [ $umur1 != '' ]
				then
					nomor1=`echo "$nomor" | grep -E ^\-?[0-9]*\.?[0-9]+$`
					if [ $nomor1 != '' ]
					then
						jeniskelamin1=`echo "$jeniskelamin" | grep -E ^\-?[0-9]*\.?[0-9]+$`
						if ! [ $jeniskelamin1 != '' ]
						then
							zenity --question --text "Apakah data yang dimasukan sudah benar?" --no-wrap --ok-label "Yes" --cancel-label "No" --width 500
		
							if [ $? -eq 0 ]
							then
								fi=$(find /root/Documents/project_bash/datapasien -name $ktp.txt)
								if [ "$fi" = "/root/Documents/project_bash/datapasien/$ktp.txt" ]
									then 
									zenity --warning --title="OOOPS" --text="DATA PASIEN SUDAH ADA DALAM DATABSE" --width 500 ;
									f_tampilan_resepsionist
								else
									touch /root/Documents/project_bash/datapasien/$ktp.txt
									echo "$ktp@$nama@$umur@$alamat@$nomor@$jeniskelamin@$tanggal" >> /root/Documents/project_bash/datapasien/$ktp.txt
									zenity --info --text "Berhasil menambahkan data pasien dalam database" --width 500
									f_sakit
								fi
							else
								zenity --info --text "Gagal menambahkan data pasien" --width 500
								f_tampilan_resepsionist
							fi
						else
							zenity --warning --title="oops" --text="jenis kelamin harus menggunakan format huruf" --width 500 ;
							f_tambah_pasien
						fi
					else
						zenity --warning --title="oops" --text="nomor harus menggunakan format angka" --width 500 ;
						f_tambah_pasien
					fi
				else
					zenity --warning --title="oops" --text="umur harus menggunakan format angka" --width 500 ;
					f_tambah_pasien
				fi
			else
				zenity --warning --title="oops" --text="nama harus menggunakan format huruf" --width 500 ;
				f_tambah_pasien
			fi
		else
			zenity --warning --title="oops" --text="masukan 12 digit no ktp" --width 500 ;
			f_tambah_pasien
		fi
     else
		zenity --warning --title="oops" --text="noktp harus menggunakan format angka" --width 500 ;
        f_tambah_pasien
	fi
}
f_sakit () {
	pilih="$(zenity --title PUSKESMAS_MILIK_KITA --height=300 --width 500 --list --radiolist --text 'pilih menu yang di inginkan:' --column 'pilih' --column 'menu' FALSE 'POLI_UMUM' FALSE 'POLI_GIGI' FALSE 'UGD' FALSE 'KELUAR')";	
	case "$pilih" in
        POLI_UMUM)
            f_poli_umum_resepsionist
            ;;
         
        POLI_GIGI)
            f_poli_gigi_resepsionist
            ;;
         
        UGD)
            f_ugd_resepsionist
            ;;
        KELUAR)
			exit
			;;
         
        *)
            zenity --warning --title="oops" --text="PROGRAM DI TUTUP" --width 500 ;
            exit
 
	esac
}

f_poli_umum_resepsionist () {
		while read line ; do		
			antrian=$line	
		done < antrian_poli_umum.txt
		poli="poli umum"
		antrian1="$(($antrian+1))"
		echo "$antrian1" >> antrian_poli_umum.txt
		if grep "$poli" harga_poli.txt; 
		then 
			harga=` grep "$poli" harga_poli.txt`
			hargareal=`echo "$harga" | cut -d'!' -f2`
			echo $hargareal
			zenity --info --text "HARGA POLI UMUM ADALAH: $hargareal" --width 500
			uang=$(zenity --forms --title "SELAMAT DATANG DI PUSKESMAS MILIK KITA" --text  "MASUKAN UANG" --add-entry="UANG" --width=500);
			echo $uang
			if [[ $uang -eq $hargareal ]]
			then 
				zenity --info --text "NOMOR ANTRIAN POLI UMUM $ktp ADALAH: $antrian1" --width 500
				tanggal=$(date "+%D %T")
				echo "$ktp@$poli@$antrian1@$hargareal@$tanggal" >> /root/Documents/project_bash/datapasien/$ktp.txt
				zenity --info --text "TRANSAKSI BERHASIL" --width 500
				f_tampilan_resepsionist
			elif [[ $uang -gt $hargareal ]]
			then
				kembalian="$(($uang-$hargareal))"
				zenity --info --text "KEMBALIAN ANDA ADALAH: $kembalian" --width 500
				zenity --info --text "NOMOR ANTRIAN POLI UMUM $ktp ADALAH: $antrian1" --width 500
				tanggal=$(date "+%D %T")
				echo "$ktp@$poli@$antrian1@$hargareal@$tanggal" >> /root/Documents/project_bash/datapasien/$ktp.txt
				zenity --info --text "TRANSAKSI BERHASIL" --width 500
				f_tampilan_resepsionist
			else
				zenity --info --text "UANG YANG DIMASUKAN KURANG" --width 500
				f_poli_umum_resepsionist
			fi
		else 
		 zenity --warning --title="oops" --text="tidak ada data harga poli" --width 500 ;
		 f_tampilan_resepsionist
		fi

}
f_poli_gigi_resepsionist () {
		while read line ; do		
			antrian=$line	
		done < antrian_poli_gigi.txt
		poli="poli gigi"
		antrian1="$(($antrian+1))"
		echo "$antrian1" >> antrian_poli_gigi.txt
		if grep "$poli" harga_poli.txt; 
		then 
			harga=` grep "$poli" harga_poli.txt`
			hargareal=`echo "$harga" | cut -d'!' -f2`
			zenity --info --text "HARGA POLI GIGI ADALAH: $hargareal" --width 500
			uang=$(zenity --forms --title "SELAMAT DATANG DI PUSKESMAS MILIK KITA" --text  "MASUKAN UANG" --add-entry="UANG" --width=500);
			echo $uang
			if [[ $uang -eq $hargareal ]]
			then 
				zenity --info --text "NOMOR ANTRIAN POLI GIGI $ktp ADALAH: $antrian1" --width 500
				tanggal=$(date "+%D %T")
				echo "$ktp@$poli@$antrian1@$hargareal@$tanggal" >> /root/Documents/project_bash/datapasien/$ktp.txt
				zenity --info --text "TRANSAKSI BERHASIL" --width 500
				f_tampilan_resepsionist
			elif [[ $uang -gt $hargareal ]]
			then
				kembalian="$(($uang-$hargareal))"
				zenity --info --text "KEMBALIAN ANDA ADALAH: $kembalian" --width 500
				zenity --info --text "NOMOR ANTRIAN POLI GIGI $ktp ADALAH: $antrian1" --width 500
				tanggal=$(date "+%D %T")
				echo "$ktp@$poli@$antrian1@$hargareal@$tanggal" >> /root/Documents/project_bash/datapasien/$ktp.txt
				zenity --info --text "TRANSAKSI BERHASIL" --width 500
				f_tampilan_resepsionist
			else
				zenity --info --text "UANG YANG DIMASUKAN KURANG" --width 500
				f_poli_umum_resepsionist
			fi
		else 
		 zenity --warning --title="oops" --text="tidak ada data harga poli" --width 500 ;
		 f_pass
		fi

}

f_ugd_resepsionist () {
		poli="ugd"
		if grep "$poli" harga_poli.txt; 
		then 
			harga=` grep "$poli" harga_poli.txt`
			hargareal=`echo "$harga" | cut -d'!' -f2`
			zenity --info --text "HARGA UGD ADALAH: $hargareal" --width 500
			uang=$(zenity --forms --title "SELAMAT DATANG DI PUSKESMAS MILIK KITA" --text  "MASUKAN UANG" --add-entry="UANG" --width=500);
			echo $uang
			if [[ $uang -eq $hargareal ]]
			then
				tanggal=$(date "+%D %T")
				echo "$ktp@$poli@$hargareal@$tanggal" >> /root/Documents/project_bash/datapasien/$ktp.txt
				zenity --info --text "TRANSAKSI BERHASIL" --width 500
				f_tampilan_resepsionist
			elif [[ $uang -gt $hargareal ]]
			then
				kembalian="$(($uang-$hargareal))"
				zenity --info --text "KEMBALIAN ANDA ADALAH: $kembalian" --width 500
				tanggal=$(date "+%D %T")
				echo "$ktp@$poli@$hargareal@$tanggal" >> /root/Documents/project_bash/datapasien/$ktp.txt
				zenity --info --text "TRANSAKSI BERHASIL" --width 500
				f_tampilan_resepsionist
			else
				zenity --info --text "UANG YANG DIMASUKAN KURANG" --width 500
				f_poli_umum_resepsionist
			fi
		else 
		 zenity --warning --title="oops" --text="tidak ada data harga poli" --width 500 ;
		 f_pass
		fi
		
}

f_tampilan_dokter() {
	pilih="$(zenity --title PUSKESMAS_MILIK_KITA --height=300 --width 500 --list --radiolist --text 'pilih menu yang di inginkan:' --column 'pilih' --column 'menu' FALSE 'PERIKSA_PASIEN' FALSE 'CEK_RIWAYAT_SAKIT' FALSE 'EDIT_AKUN' FALSE 'HAPUS_AKUN' FALSE 'KELUAR')";	
	case "$pilih" in
        PERIKSA_PASIEN)
            f_tampilan_periksa
            ;;
         
        CEK_RIWAYAT_SAKIT)
            f_cek_riwayat_sakit
            ;;
        EDIT_AKUN)
            f_edit_akun
            ;;
        HAPUS_AKUN)
			f_hapus_akun
			;;
        KELUAR)
			exit
			;;
         
        *)
            zenity --warning --title="oops" --text="PROGRAM DI TUTUP" --width 500 ;
            exit
 
	esac
}
f_tampilan_periksa() {
	pilih="$(zenity --title PUSKESMAS_MILIK_KITA --height=300 --width 500 --list --radiolist --text 'pilih menu yang di inginkan:' --column 'pilih' --column 'menu' FALSE 'PASIEN_BIASA' FALSE 'UGD' FALSE 'KELUAR')";	
	case "$pilih" in
        PASIEN_BIASA)
            f_periksa_pasien
            ;;
         
        UGD)
            f_periksa_ugd
            ;;
        KELUAR)
			exit
			;;
         
        *)
            zenity --warning --title="oops" --text="PROGRAM DI TUTUP" --width 500 ;
            exit
 
	esac
}

f_periksa_pasien () {
	ktp=`zenity --forms --title="DATA PASIEN" --text="" --add-entry="NOMOR KTP PASIEN"`
	check=`echo "$ktp" | grep -E ^\-?[0-9]*\.?[0-9]+$`
	if [ "$check" != '' ]
    then
        jumlah=""${#ktp}""
        echo $jumlah
		if [ "$jumlah" = 12 ]
		then
			fi=$(find /root/Documents/project_bash/datapasien -name $ktp.txt)
			if [ "$fi" = "/root/Documents/project_bash/datapasien/$ktp.txt" ]
				then 
				keluhan="$(zenity --forms --title "SELAMAT DATANG DI PUSKESMAS MILIK KITA" --text  "MASUKAN KELUHAN PASIEN" --add-entry="KELUHAN" --width=500)";
				diagnosa="$(zenity --forms --title "SELAMAT DATANG DI PUSKESMAS MILIK KITA" --text  "MASUKAN DIAGNOSA DOKTER" --add-entry="DIAGNOSA" --width=500)";
				arraypilih=(1 2 3 4 5 6 7 8 9 10)
				angkaobat=$(zenity --entry --title "berapa obat yang dibutuhkan pasien untuk sembuh" --entry-text "${arraypilih[@]}" --text "Pilih salah satu" --width=500)
				counter=0
				obatke=1
				until [ $counter -eq $angkaobat ]
				do
					indexnama=1
					arrayobat[0]=""
					srt=$(sort data_obat_harga.txt)
					touch xsudahdisortingx.txt
					echo "$srt" > xsudahdisortingx.txt
					while read line ; do		
						arrayobat[$indexnama]=`echo $line | cut -d'/' -f1`
						indexnama=$(($indexnama+1))	
					done < xsudahdisortingx.txt
					value=$(zenity --entry --title "pilihan obat ke$obatke" --entry-text "${arrayobat[@]}" --text "pilih satu")
					((obatke++))
				  namaobatyangdipilih[$counter]="$value"
				  ((counter++))
				done
				tanggal=$(date "+%D %T")
				echo "$ktp@$keluhan@$diagnosa@${namaobatyangdipilih[@]}@$UserName@$tanggal" >> /root/Documents/project_bash/datapasien/$ktp.txt
				zenity --info --text "Berhasil menambahkan data pasien dalam database" --width 500
				f_tampilan_dokter
			else
			zenity --warning --title="oops" --text="BELUM ADA PASIEN DENGAN NOMOR KTP $tampil, MOHON MENDAFTAR DAHULU" --width 500 ;
			f_tampilan_dokter_umum
			fi
		else
			
			zenity --warning --title="oops" --text="harap masukan 12 digit no ktp" --width 500 ;
			f_poli_umum_dokter
			
		fi
     else
		zenity --warning --title="oops" --text="no ktp harus menggunakan format angka" --width 500 ;
        f_poli_umum_dokter
	fi
}	
f_periksa_ugd () {
	ktp=`zenity --forms --title="DATA PASIEN" --text="" --add-entry="NOMOR KTP PASIEN"`
	check=`echo "$ktp" | grep -E ^\-?[0-9]*\.?[0-9]+$`
	if [ "$check" != '' ]
    then
        jumlah=""${#ktp}""
        echo $jumlah
		if [ "$jumlah" = 12 ]
		then
			fi=$(find /root/Documents/project_bash/datapasien -name $ktp.txt)
			if [ "$fi" = "/root/Documents/project_bash/datapasien/$ktp.txt" ]
				then 
				diagnosa="$(zenity --forms --title "SELAMAT DATANG DI PUSKESMAS MILIK KITA" --text  "MASUKAN DIAGNOSA DOKTER" --add-entry="DIAGNOSA" --width=500)";
				arraypilih=(1 2 3 4 5 6 7 8 9 10)
				angkaobat=$(zenity --entry --title "berapa obat yang dibutuhkan pasien untuk sembuh" --entry-text "${arraypilih[@]}" --text "Pilih salah satu" --width=500)
				counter=0
				obatke=1
				until [ $counter -eq $angkaobat ]
				do
					indexnama=1
					arrayobat[0]=""
					srt=$(sort data_obat_harga.txt)
					touch xsudahdisortingx.txt
					echo "$srt" > xsudahdisortingx.txt
					while read line ; do		
						arrayobat[$indexnama]=`echo $line | cut -d'/' -f1`
						indexnama=$(($indexnama+1))	
					done < xsudahdisortingx.txt
					value=$(zenity --entry --title "pilihan obat ke$obatke" --entry-text "${arrayobat[@]}" --text "pilih satu")
					((obatke++))
				  namaobatyangdipilih[$counter]="$value"
				  ((counter++))
				done
				tanggal=$(date "+%D %T")
				echo "$ktp@$diagnosa@${namaobatyangdipilih[@]}@$UserName@$tanggal" >> /root/Documents/project_bash/datapasien/$ktp.txt
				zenity --info --text "Berhasil menambahkan data pasien dalam database" --width 500
				f_tampilan_dokter
			else
			zenity --warning --title="oops" --text="BELUM ADA PASIEN DENGAN NOMOR KTP $tampil, MOHON MENDAFTAR DAHULU" --width 500 ;
			f_tampilan_dokter_umum
			fi
		else
			
			zenity --warning --title="oops" --text="harap masukan 12 digit no ktp" --width 500 ;
			f_poli_umum_dokter
			
		fi
     else
		zenity --warning --title="oops" --text="no ktp harus menggunakan format angka" --width 500 ;
        f_poli_umum_dokter
	fi
}
f_cek_riwayat_sakit () {
	ktp=`zenity --forms --title="DATA PASIEN" --text="" --add-entry="NOMOR KTP PASIEN"`
	check=`echo "$ktp" | grep -E ^\-?[0-9]*\.?[0-9]+$`
	if [ "$check" != '' ]
    then
        jumlah=""${#ktp}""
        echo $jumlah
		if [ "$jumlah" = 12 ]
		then
			fi=$(find /root/Documents/project_bash/datapasien -name $ktp.txt)
			if [ "$fi" = "/root/Documents/project_bash/datapasien/$ktp.txt" ]
			then 
				tampil=`cat /root/Documents/project_bash/datapasien/$ktp.txt`
				zenity --info --text "$tampil" --width 1000
				f_tampilan_dokter
			else
			zenity --warning --title="oops" --text="BELUM ADA PASIEN DENGAN NOMOR KTP $tampil, MOHON MENDAFTAR TERLEBIH DAHULU" --width 500 ;
			f_tampilan_dokter_umum
			fi
		else
			
			zenity --warning --title="oops" --text="harap masukan 12 digit no ktp" --width 500 ;
			f_poli_umum_dokter
			
		fi
     else
		zenity --warning --title="oops" --text="no ktp harus menggunakan format angka" --width 500 ;
        f_poli_umum_dokter
	fi	
}	
f_tampilan_admin () {
	pilih="$(zenity --title PUSKESMAS_MILIK_KITA --height=300 --width 500 --list --radiolist --text 'pilih menu yang di inginkan:' --column 'pilih' --column 'menu' FALSE 'EDIT_PEGAWAI' FALSE 'EDIT_HARGA_POLI' FALSE 'EDIT_OBAT' FALSE 'HAPUS_AKUN' FALSE 'KELUAR')";	
	case "$pilih" in
        EDIT_PEGAWAI)
            f_pegawai_admin
            ;;
         
        EDIT_HARGA_POLI)
            f_edit_harga_poli
            ;;
            
        EDIT_OBAT)
            f_edit_obat
            ;;
        HAPUS_AKUN)
            f_hapus_akun
            ;;
        KELUAR)
			exit
			;;
         
        *)
            zenity --warning --title="oops" --text="PROGRAM DI TUTUP" --width 500 ;
            exit
 
	esac
}
f_pegawai_admin () {
	pilih="$(zenity --title PUSKESMAS_MILIK_KITA --height=300 --width 500 --list --radiolist --text 'pilih menu yang di inginkan:' --column 'pilih' --column 'menu' FALSE 'TAMBAH_PEGAWAI' FALSE 'HAPUS_PEGAWAI' FALSE 'KELUAR')";	
	case "$pilih" in
        TAMBAH_PEGAWAI)
            f_tambah_pegawai
            ;;
         
        EDIT_PEGAWAI)
            f_edit_pegawai
            ;;
            
        HAPUS_PEGAWAI)
            f_hapus_pegawai
            ;;
        KELUAR)
			exit
			;;
         
        *)
            zenity --warning --title="oops" --text="PROGRAM DI TUTUP" --width 500 ;
            exit
 
	esac
	
}
f_tambah_pegawai () {
	user="$(zenity --forms --title "SELAMAT DATANG DI PUSKESMAS MILIK KITA" --text  "MASUKAN USERNAME PEGAWAI BARU" --add-entry="USERNAME" --width=500)";
	pass="$(zenity --forms --title "SELAMAT DATANG DI PUSKESMAS MILIK KITA" --text  "MASUKAN PASSWORD PEGAWAI" --add-entry="PASSWORD" --width=500)";
	jabatan="$(zenity --title PUSKESMAS_MILIK_KITA --height=300 --width 500 --list --radiolist --text 'pilih menu yang di inginkan:' --column 'pilih' --column 'menu jabatan' FALSE 'dokter' FALSE 'resepsionist' FALSE 'superadmin')";
	echo "$user!$pass!$jabatan" >> password.txt
	zenity --info --text "Berhasil menambahkan data pegawai dalam database" --width 500
	f_tampilan_admin
}
f_edit_akun () {
	if grep "$userpas" password.txt; 
	then 	
			pilih="$(zenity --title PUSKESMAS_MILIK_KITA --height=300 --width 500 --list --radiolist --text 'pilih yang ingin di edit:' --column 'pilih' --column 'menu' FALSE 'username' FALSE 'password' FALSE 'KELUAR')";	
			case "$pilih" in
				username)
						username="$(zenity --forms --title "SELAMAT DATANG DI PUSKESMAS MILIK KITA" --text  "MASUKAN USERNAME BARU" --add-entry="USERNAME" --width=500)";
						datausername=` grep "$userpas" password.txt`
						position=`echo "$datausername" | cut -d'!' -f3`
						data=$userpas!$position
						echo $data
						databaru=$username!$Password!$position
						echo $databaru
						sed -i  "s/${data}/${databaru}/g" password.txt
						zenity --info --text "Berhasil mengubah username dari $user ke $username" --width 500
						if [ $position = "resepsionist" ]
						then
							f_tampilan_resepsionist
						else
							f_tampilan_dokter
						fi
					;;
				 
				password)
						passw="$(zenity --forms --title "SELAMAT DATANG DI PUSKESMAS MILIK KITA" --text  "MASUKAN PASSWORD BARU" --add-entry="PASSWORD" --width=500)";
						datausername=` grep "$userpas" password.txt`
						position=`echo "$datausername" | cut -d'!' -f3`
						data=$userpas!$position
						echo $data
						databaru=$UserName!$passw!$position
						echo $databaru
						sed -i  "s/${data}/${databaru}/g" password.txt
						zenity --info --text "Berhasil mengubah password dari $pass ke $passw" --width 500
						if [ $position = "resepsionist" ]
						then
							f_tampilan_resepsionist
						else
							f_tampilan_dokter
						fi
					;;
					
				jabatan)
						jabat="$(zenity --title PUSKESMAS_MILIK_KITA --height=300 --width 500 --list --radiolist --text 'pilih menu yang di inginkan:' --column 'pilih' --column 'menu jabatan' FALSE 'dokter' FALSE 'resepsionist' FALSE 'superadmin')";
						datausername=` grep "$userpas" password.txt`
						position=`echo "$datausername" | cut -d'!' -f3`
						data=$user!$pass!$position
						echo $data
						databaru=$user!$pass!$jabat
						echo $databaru
						sed -i  "s/${data}/${databaru}/g" password.txt
						zenity --info --text "Berhasil mengubah jabatan dari $position ke $jabat" --width 500
						f_tampilan_admin
					;;
				KELUAR)
					exit
					;;
				 
				*)
					zenity --warning --title="oops" --text="PROGRAM DI TUTUP" --width 500 ;
					exit
		 
			esac
			

	else 
	 zenity --warning --title="oops" --text="nama atau password yag anda maskan salah" --width 500 ;
	 f_edit_pegawai
	fi
	
}
f_hapus_pegawai () {
	indexnama=1
	arrayobat[0]=""
	srt=$(sort password.txt)
	touch xsudahdisortingx.txt
	echo "$srt" > xsudahdisortingx.txt
	while read line ; do		
		arrayobat[$indexnama]=`echo $line | cut -d'!' -f1`
		indexnama=$(($indexnama+1))	
	done < xsudahdisortingx.txt
	value=$(zenity --entry --title "pilih pegawai" --entry-text "${arrayobat[@]}" --text "pilih satu")
	sed -i "/${value}/d" password.txt
	zenity --info --text "Berhasil menghapus pegawai dalam database" --width 500
	f_tampilan_admin
	
}
f_hapus_akun () {
	sed -i "/${userpas}/d" password.txt
	zenity --info --text "Berhasil menghapus akun dalam database" --width 500
	f_pass
}
f_edit_harga_poli () {
	room="$(zenity --title PUSKESMAS_MILIK_KITA --height=300 --width 500 --list --radiolist --text 'pilih menu yang di inginkan:' --column 'pilih' --column 'menu yang akan di edit' FALSE 'POLI_UMUM' FALSE 'POLI_GIGI' FALSE 'UGD')";
	case "$room" in
        POLI_UMUM)
				poli="poli umum"
				harga=`zenity --forms --title="EDIT HARGA" --text="" --add-entry="HARGA BARU"`
				check=`echo "$harga" | grep -E ^\-?[0-9]*\.?[0-9]+$`
				if [ "$check" != '' ]
				then
						dataharga=` grep "$poli" harga_poli.txt`
						hargaawal=`echo "$dataharga" | cut -d'!' -f2`
						dataawal=$poli!$hargaawal
						dataakhir=$poli!$harga
						sed -i  "s/${dataawal}/${dataakhir}/g" harga_poli.txt
						zenity --info --text "Berhasil mengubah harga menjadi $harga" --width 500
						f_tampilan_admin
				else
					zenity --warning --title="oops" --text="harus menggunakan format angka" --width 500 ;
					f_tampilan_admin
				fi	
            ;;
         
        POLI_GIGI)
				poli="poli gigi"
				harga=`zenity --forms --title="EDIT HARGA" --text="" --add-entry="HARGA BARU"`
				check=`echo "$harga" | grep -E ^\-?[0-9]*\.?[0-9]+$`
				if [ "$check" != '' ]
				then
						dataharga=` grep "$poli" harga_poli.txt`
						hargaawal=`echo "$dataharga" | cut -d'!' -f2`
						dataawal=$poli!$hargaawal
						dataakhir=$poli!$harga
						sed -i  "s/${dataawal}/${dataakhir}/g" harga_poli.txt
						zenity --info --text "Berhasil mengubah harga menjadi $harga" --width 500
						f_tampilan_admin
				else
					zenity --warning --title="oops" --text="harus menggunakan format angka" --width 500 ;
					f_tampilan_admin
				fi	
            ;;
            
        UGD)
				poli="ugd"
				harga=`zenity --forms --title="EDIT HARGA" --text="" --add-entry="HARGA BARU"`
				check=`echo "$harga" | grep -E ^\-?[0-9]*\.?[0-9]+$`
				if [ "$check" != '' ]
				then
						dataharga=` grep "$poli" harga_poli.txt`
						hargaawal=`echo "$dataharga" | cut -d'!' -f2`
						dataawal=$poli!$hargaawal
						dataakhir=$poli!$harga
						sed -i  "s/${dataawal}/${dataakhir}/g" harga_poli.txt
						zenity --info --text "Berhasil mengubah harga menjadi $harga" --width 500
						f_tampilan_admin
				else
					zenity --warning --title="oops" --text="no ktp harus menggunakan format angka" --width 500 ;
					f_tampilan_admin
				fi	
            ;;
        KELUAR)
			exit
			;;
         
        *)
            zenity --warning --title="oops" --text="PROGRAM DI TUTUP" --width 500 ;
            exit
 
	esac
	
}
f_edit_obat () {
	pilih="$(zenity --title PUSKESMAS_MILIK_KITA --height=300 --width 500 --list --radiolist --text 'pilih menu yang di inginkan:' --column 'pilih' --column 'menu' FALSE 'TAMBAH_OBAT' FALSE 'EDIT_NAMA_OBAT' FALSE 'HAPUS_OBAT' FALSE 'KELUAR')";	
	case "$pilih" in
        TAMBAH_OBAT)
				nama="$(zenity --forms --title "SELAMAT DATANG DI PUSKESMAS MILIK KITA" --text  "MASUKAN USERNAME PEGAWAI BARU" --add-entry="USERNAME" --width=500)";
				if grep "$nama" data_obat_harga.txt
				then
					zenity --info --text "Data obat sudah ada dalam database" --width 500
					f_tampilan_admin
				else
					echo "$nama" >> data_obat_harga.txt
					zenity --info --text "Berhasil menambahkan data obat dalam database" --width 500
					f_tampilan_admin
				fi
            ;;
         
        EDIT_NAMA_OBAT)
				indexnama=1
				arrayobat[0]=""
				srt=$(sort data_obat_harga.txt)
				touch xsudahdisortingx.txt
				echo "$srt" > xsudahdisortingx.txt
				while read line ; do		
					arrayobat[$indexnama]=`echo $line | cut -d'/' -f1`
					indexnama=$(($indexnama+1))	
				done < xsudahdisortingx.txt
				value=$(zenity --entry --title "pilih obat" --entry-text "${arrayobat[@]}" --text "pilih satu")
				nama="$(zenity --forms --title "SELAMAT DATANG DI PUSKESMAS MILIK KITA" --text  "MASUKAN NAMA OBAT BARU" --add-entry="NAMA OBAT" --width=500)";
				sed -i  "s/${value}/${nama}/g" data_obat_harga.txt
				zenity --info --text "Berhasil mengubah data obat dalam database" --width 500
				f_tampilan_admin
            ;;
            
        HAPUS_OBAT)
				indexnama=1
				arrayobat[0]=""
				srt=$(sort data_obat_harga.txt)
				touch xsudahdisortingx.txt
				echo "$srt" > xsudahdisortingx.txt
				while read line ; do		
					arrayobat[$indexnama]=`echo $line | cut -d'/' -f1`
					indexnama=$(($indexnama+1))	
				done < xsudahdisortingx.txt
				value=$(zenity --entry --title "pilih obat" --entry-text "${arrayobat[@]}" --text "pilih satu")
				sed -i "/${value}/d" data_obat_harga.txt
				zenity --info --text "Berhasil menghapus obat dalam database" --width 500
				f_tampilan_admin
            ;;
        KELUAR)
			exit
			;;
         
        *)
            zenity --warning --title="oops" --text="PROGRAM DI TUTUP" --width 500 ;
            exit
 
	esac
	
}
f_reset_antrian () {
		echo -n 0 > antrian_poli_umum.txt
		echo -n 0 > antrian_poli_gigi.txt
		zenity --info --text "Berhasil mereset antrian" --width 500
		f_tampilan_resepsionist
}
f_pass
