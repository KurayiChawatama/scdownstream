process SCANPY_NEIGHBORS {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/7e/7e8ccc771255d161988a15931fdc64fb637e43d65946a78697c5aceffa395902/data'
        : 'community.wave.seqera.io/library/python-igraph_pyyaml_scanpy:cc0304f4731f72f9'}"

    input:
    tuple val(meta), path(h5ad, arity: 1)
    val(rep)

    output:
    tuple val(meta), path("${prefix}.h5ad"), emit: h5ad
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: "${meta.id}_neighbors"
    template('neighbors.py')

    stub:
    prefix = task.ext.prefix ?: "${meta.id}_neighbors"
    """
    touch ${prefix}.h5ad
    touch versions.yml
    """
}
