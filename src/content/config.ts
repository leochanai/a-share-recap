import { defineCollection, z } from 'astro:content';

const reportsCollection = defineCollection({
  type: 'content',
  schema: z.object({
    date: z.string(),
    type: z.string(),
    tags: z.array(z.string()),
  }),
});

export const collections = {
  reports: reportsCollection,
};
