type BoundaryContent = {
  eyebrow: string;
  title: string;
  intro: string;
  items: string[];
};

export function BoundarySection({ content }: { content: BoundaryContent }) {
  return (
    <section className="section boundary-section" id="boundaries">
      <div className="section-copy">
        <p className="eyebrow">{content.eyebrow}</p>
        <h2>{content.title}</h2>
        <p>{content.intro}</p>
      </div>
      <ul className="boundary-list">
        {content.items.map((item) => (
          <li key={item}>
            <span aria-hidden="true" />
            {item}
          </li>
        ))}
      </ul>
    </section>
  );
}
