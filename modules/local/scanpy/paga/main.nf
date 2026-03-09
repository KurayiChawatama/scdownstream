process SCANPY_PAGA {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/7e/7e8ccc771255d161988a15931fdc64fb637e43d65946a78697c5aceffa395902/data'
        : 'community.wave.seqera.io/library/python-igraph_pyyaml_scanpy:cc0304f4731f72f9'}"

    input:
    tuple val(meta), path(h5ad)

    output:
    tuple val(meta), path("*.h5ad"), emit: h5ad, optional: true
    path("*.pkl")                  , emit: uns, optional: true
    path("*.npy")                  , emit: obsp, optional: true
    path("*.png")                  , emit: plot, optional: true
    path("*_mqc.json")             , emit: multiqc_files, optional: true
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    obs_key = meta.obs_key ?: "leiden"
    prefix = task.ext.prefix ?: "${meta.id}"
    template 'paga.py'

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch "${prefix}.h5ad"
    touch "${prefix}.pkl"
    touch "${prefix}_connectivities.npy"
    touch "${prefix}.png"
    touch "${prefix}_mqc.json"
    touch "versions.yml"
    """
}
