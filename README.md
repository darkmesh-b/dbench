# multi-dbench
Benchmark Kubernetes persistent disk volumes with `fio`: Read/write IOPS, bandwidth MB/s and latency.
Forked from https://github.com/leeliu/dbench

# Usage

1. Edit dbench-statefulset.yaml, changing `storageClassName` to match your Kubernetes provider's Storage Class `kubectl get storageclasses` and updating the number of replicaas required
2. Deploy Dbench using: `kubectl apply -f dbench-statefulset.yaml`
3. Once deployed, the Dbench Job will run a daemon of fio, thus creating a set of worker nodes. NOTE: pods must have routable networking
4. Run a FIO server to run jobs on the worker nodes, see notes below
5. Once the tests are finished, clean up using: `kubectl delete -f dbench-statefulset.yaml` and delete the volumes `k get pvc | awk '/dbench/{print $1}' | xargs -I {} kubectl delete pvc {}` that should deprovision the persistent disk and delete it to minimize storage billing.

## Notes / Troubleshooting

### FIO SERVER

1. Download an Ubuntu image.
2. Install requirements: `sudo apt install gcc make zlib1g-dev`
3. Clone FIO: `git clone https://github.com/axboe/fio.git`
4. Make & install FIO: 

```
cd fio
./configure
make
sudo make install
```

5. Define an FIO file (see example.fio)
6. Obtain the IP addresses of the pods, e.g.: <br>
`seq 0 15 | xargs -I {} bash -c 'kubectl get pod multi-dbench-{} --template '{{.status.podIP}}';echo' > fio_workers`
7. Run FIO, e.g.: `fio --client=fio_workers example.fio`

* If the Persistent Volume Claim is stuck on Pending, it's likely you didn't specify a valid Storage Class. Double check using `kubectl get storageclasses`. Also check that the volume size of `1000Gi` (default) is available for provisioning.
* It can take some time for a Persistent Volume to be Bound and the Kubernetes Dashboard UI will show the Dbench Job as red until the volume is finished provisioning.
* It's useful to test multiple disk sizes as most cloud providers price IOPS per GB provisioned. So a `4000Gi` volume will perform better than a `1000Gi` volume. Just edit the yaml, `kubectl delete -f dbench.yaml` and run `kubectl apply -f dbench.yaml` again after deprovision/delete completes.
* A list of all `fio` tests are in [docker-entrypoint.sh](https://github.com/logdna/dbench/blob/master/docker-entrypoint.sh).

## Contributors

* Lee Liu (LogDNA)
* [Alexis Turpin](https://github.com/alexis-turpin)
* Dharmesh Bhatt

## License

* MIT
