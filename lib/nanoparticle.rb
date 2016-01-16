module OpenTox

  class Nanoparticle
    include OpenTox

    attr_accessor :name, :uri, :tox, :p_chem, :core, :coating

  end
end
