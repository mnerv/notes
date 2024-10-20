<script lang="ts">
  import { onMount } from 'svelte';
  import File from './File.svelte';
  import { type NodeT } from './FileTree'

  export let tree: NodeT
  let isCollapse = true
  
  onMount(async () => {
    const collapse = localStorage.getItem(tree.key)
    if (collapse) isCollapse = JSON.parse(collapse)
  })
</script>

<File title={tree.name} level={tree.level} href={tree.href} info={`${tree.children.length}`} isExpand={!isCollapse} on:click={() => {
    isCollapse = !isCollapse
    localStorage.setItem(tree.key, JSON.stringify(isCollapse))
  }
}/>

{#if Array.isArray(tree.children)}
<div class="overflow-hidden {isCollapse ? 'max-h-0' : 'max-h-max'}">
  {#each tree.children as child}
    <svelte:self tree={child} />
  {/each}
</div>
{/if}
