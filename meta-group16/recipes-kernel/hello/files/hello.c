/******************************************************************************
 *
 *   Copyright (C) 2011  Intel Corporation. All rights reserved.
 *
 *   This program is free software;  you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; version 2 of the License.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY;  without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
 *   the GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program;  if not, write to the Free Software
 *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 *
 *****************************************************************************/

#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

MODULE_VERSION("0.1");
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Juho Pyykkonen");
MODULE_AUTHOR("Maxim Kyner");

MODULE_AUTHOR("Trinh Gia Huy");
MODULE_DESCRIPTION("A simple linux kernel module, which can be loaded and unloaded");
MODULE_LICENSE("GPL");

static char *name = "world";
module_param(name, charp, S_IRUGO);

static int __init hello_init(void)
{
	printk("Hello great %s !\n", name);
	return 0;
}

static void __exit hello_exit(void)
{
	printk("Goodbye %s !\n", name);
}

module_init(hello_init);
module_exit(hello_exit);

