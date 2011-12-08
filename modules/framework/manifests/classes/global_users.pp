class framework::global_users {
	user{
		"karl":
			comment=>"Karl Pietri",
			ensure=>present,
			uid=>1189,
			gid=>100,
			groups=>[puppet],
			managehome=>true,
			password=>'$1$0001e09a$teB34GZNx5ljnEBz9eX/I1',
			shell=>"/bin/bash",
			home=>"/home/karl"
	}
	rFile{[
		"/home/karl/.bashrc",
		"/home/karl/.nanorc",
		]:
			owner=>karl,
			group=>users,
			require=>User["karl"]
	}
	ssh_authorized_key {
		"karlskey":
			key=>"AAAAB3NzaC1kc3MAAACBAMLi/j5lkh9edFmGoeF9rvgNV2R5KBC4Y7OwlQZmMuqM4OuloNha3rse08aOtC+nyygCkuiA9njR6ptcdnpAy0ISVaEMAY0mSphSWXHysq1a2FBGteOKu2GnlMpxoT2RfFB+b0hQt8wrKLrCbqpSvAThNjOCvYnlr5R9ppSWPxQrAAAAFQDvsRZ23J7P7FH4yLMyymhSWdKVaQAAAIBBtCuTqknOCuZpEjkNUFPTuf2OORCSCBYa6aDwFizpX7LqQeYEI2BY5EXmzoL/+1Rv1m5hZ3a2FP4C4rkon0YLcM50rejFF5xlSzgZ5qCAqlHm6f1ec8E6AT+OD9/8ELl3iBMCrQDRib+EF9RRsNhufADDymGY7CRC26gVI195AQAAAIA6AltqZAVMBP/P8SqRrCoMXBZOfG/INz/1LRbyCQBM0UZbDRwav19mep+MHA4H9f1MQnjphLhewPphjTsSJe6pT2XQrCsel7CJgdb7OlAtNiICY3X5sS5uFHJGVNWmZQ8h8x4mbEEzI4irgdHWutqIDRmDrWEfea3gErE1mQ3wng==",
			ensure=>present,
			type=>ssh-dss,
			user=>karl,
			target=>"/home/karl/.ssh/authorized_keys",
			require=>User["karl"]
	}

}
