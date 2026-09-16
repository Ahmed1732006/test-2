-- MIDAD — إضافة نظام "زر التحميل + زر العرض" والتحكم اليدوي في download-only.html
-- شغّل هذا الملف مرة واحدة في Supabase SQL Editor.
-- كل الأعمدة الجديدة اختيارية ولها قيم افتراضية، فمش هتأثر على أي مواد موجودة حاليًا
-- (تفتكر: button_mode الافتراضي = 'both' يعني هيظهر زر "عرض" جنب زر "تحميل" تلقائيًا لكل المواد،
--  وتقدر تغيّره لأي مادة من نافذة "تعديل المستطيل").

alter table public.materials
  add column if not exists button_mode text not null default 'both',
  add column if not exists preview_override text not null default 'auto',
  add column if not exists dlonly_source_type text,
  add column if not exists dlonly_file_path text,
  add column if not exists dlonly_link text,
  add column if not exists dlonly_display_name text,
  add column if not exists dlonly_target text;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'materials_button_mode_check') then
    alter table public.materials
      add constraint materials_button_mode_check
      check (button_mode in ('download','preview','both'));
  end if;

  if not exists (select 1 from pg_constraint where conname = 'materials_preview_override_check') then
    alter table public.materials
      add constraint materials_preview_override_check
      check (preview_override in ('auto','download_only'));
  end if;

  if not exists (select 1 from pg_constraint where conname = 'materials_dlonly_source_type_check') then
    alter table public.materials
      add constraint materials_dlonly_source_type_check
      check (dlonly_source_type is null or dlonly_source_type in ('upload','link'));
  end if;

  if not exists (select 1 from pg_constraint where conname = 'materials_dlonly_target_check') then
    alter table public.materials
      add constraint materials_dlonly_target_check
      check (dlonly_target is null or dlonly_target in ('download','preview','both'));
  end if;
end $$;

-- شرح الأعمدة:
-- button_mode          : الأزرار الظاهرة للأعضاء على هذه المادة — 'download' | 'preview' | 'both'
-- preview_override     : 'auto' (السلوك الطبيعي) أو 'download_only' (تفعيل التحكم اليدوي أدناه)
-- dlonly_source_type   : 'upload' أو 'link' — مصدر المحتوى اللي هتعرضه download-only.html
-- dlonly_file_path     : مسار الملف المرفوع (لو المصدر upload) داخل bucket "materials"
-- dlonly_link          : الرابط المباشر (لو المصدر link)
-- dlonly_display_name  : الاسم اللي هيتكتب/يظهر جوه صفحة download-only.html
-- dlonly_target        : فين تظهر صفحة download-only.html بدل السلوك التلقائي — 'download' | 'preview' | 'both'
