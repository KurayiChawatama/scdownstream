process ADATA_SPLITEMBEDDINGS {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/fd/fd27aeaf160eaba9a58c029e08f1da74051aa292c2fb043a5dd68fddcde3af93/data':
        'community.wave.seqera.io/library/pyyaml_scanpy:3c9e9f631f45553d' }"

    input:
    tuple val(meta), path(h5ad)
    val embeddings

    output:
    tuple val(meta), path("*.h5ad"), emit: h5ad
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: "${meta.id}"
    template('split_embeddings.py')

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch scvi.h5ad
    touch versions.yml
    """
}
