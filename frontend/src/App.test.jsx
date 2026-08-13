import { render, screen } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import React from 'react';
import App from './App';

// Mock do global fetch para impedir chamadas HTTP reais no teste
global.fetch = vi.fn(() =>
  Promise.resolve({
    ok: true,
    json: () => Promise.resolve([]),
  })
);

describe('App Component', () => {
  it('renderiza o título principal do FilaFlow', () => {
    render(<App />);
    const titleElement = screen.getByText(/FilaFlow/i);
    expect(titleElement).toBeDefined();
  });
});
