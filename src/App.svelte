<script lang="ts">
  import { onMount } from 'svelte'
  import Icon from '@iconify/svelte';
  import File from './File.svelte';
  import FileTree from './FileTree.svelte';
  import { pathsToFileTree, type NodeT, sortByType } from './FileTree';

  let registry: string[] = []
  let trees: NodeT[] = []

  onMount(async () => {
    const links = await fetch('./pdf/registry.txt')
      .then(res => {
        if (res.ok) return res.text()
        else throw new Error(`Can't download registry.txt`)
      })
      .then(txt => txt.trim())
      .then(txt => txt.replaceAll('.tex', '.pdf'))
      .then(txt => txt.replaceAll('./', '/pdf/'))
      .then(txt => txt.split('\n'))
      .catch(_ => [])

    if (links.length === 0) return
    registry = links
    trees = pathsToFileTree(registry)
    trees = sortByType(trees)
  })
</script>

<main class="p-4 pb-32 md:w-[512pt] mx-auto md:items-center">
  <h1 class="text-3xl font-bold mb-5">Notes</h1>
  <div class="rounded-md overflow-hidden dark:bg-zinc-800 bg-zinc-100 w-full">
    {#each trees as tree}
      <FileTree {tree} />
    {/each}
  </div>
  <div class='fixed bottom-0 right-0 p-4 hover:text-blue-nordic'>
    <a class='mx-auto hover:underline hover:text-blue-400 transition-all duration-150 font-light'
      href='https://github.com/mnerv/maths'
      title='Open Github repository'
      target='_blank'>
      <Icon icon="bi:github" />
    </a>
  </div>
</main>
