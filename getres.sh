rsync -avr -e "ssh -p1350" --exclude "*.fq" --exclude "*.bam" newton:/mnt/scratch4/SLA-benchmarking/clean-benchmarks/sim30 .
rsync -avr -e "ssh -p1350" --exclude "*.fq" --exclude "*.bam" newton:/mnt/scratch4/SLA-benchmarking/clean-benchmarks/30percent .
rsync -avr -e "ssh -p1350" --exclude "*.fq" --exclude "*.bam" newton:/mnt/scratch4/SLA-benchmarking/clean-benchmarks/60percent .
