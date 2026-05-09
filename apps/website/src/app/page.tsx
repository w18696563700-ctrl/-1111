import { AudienceSection } from '@/components/AudienceSection';
import { BoundarySection } from '@/components/BoundarySection';
import { CapabilityBand } from '@/components/CapabilityBand';
import { CtaSection } from '@/components/CtaSection';
import { FeatureGrid } from '@/components/FeatureGrid';
import { HeroSection } from '@/components/HeroSection';
import { SiteFooter } from '@/components/SiteFooter';
import { SiteHeader } from '@/components/SiteHeader';
import { TrustStrip } from '@/components/TrustStrip';
import { WorkflowSection } from '@/components/WorkflowSection';
import {
  audience,
  boundaries,
  capabilityBand,
  features,
  finalCta,
  hero,
  trustStrip,
  workflow,
} from '@/content/site';

export default function HomePage() {
  return (
    <>
      <SiteHeader />
      <main>
        <HeroSection content={hero} />
        <TrustStrip content={trustStrip} />
        <FeatureGrid content={features} />
        <WorkflowSection content={workflow} />
        <CapabilityBand content={capabilityBand} />
        <BoundarySection content={boundaries} />
        <AudienceSection content={audience} />
        <CtaSection content={finalCta} />
      </main>
      <SiteFooter />
    </>
  );
}
