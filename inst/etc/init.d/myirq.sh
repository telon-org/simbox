#!/bin/sh


echo 8 > /proc/irq/14/smp_affinity
echo 8 > /proc/irq/44/smp_affinity
echo 8 > /proc/irq/43/smp_affinity

echo 1 > /proc/irq/16/smp_affinity
echo 2 > /proc/irq/17/smp_affinity
echo 4 > /proc/irq/18/smp_affinity
echo 4 > /proc/irq/19/smp_affinity
echo 4 > /proc/irq/23/smp_affinity






